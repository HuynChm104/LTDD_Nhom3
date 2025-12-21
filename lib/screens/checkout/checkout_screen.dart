import 'package:bongbieng_app/screens/checkout/widget/payment_method_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

// Import Widgets nội bộ
import 'order_success_screen.dart';
import 'widget/customer_info_section.dart';
import 'widget/delivery_method_section.dart';
import 'widget/order_item_section.dart';
import 'widget/payment_summary_section.dart';
import 'widget/voucher_section.dart';

// Import Models & Providers
import '../../models/order_model.dart';
import '../../models/voucher_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/branch_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/constants.dart';
import '../voucher/voucher_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<String> selectedCartItemIds;

  const CheckoutScreen({Key? key, required this.selectedCartItemIds}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _deliveryType = 0; // 0: Giao hàng, 1: Tại quán
  String _paymentMethod = 'cod';
  VoucherModel? _selectedVoucher;
  String? _selectedBranchId;
  bool _isLocating = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  void _initData() {
    if (!mounted) return;
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      _addressController.text = user.address;
    }
    final branchProvider = context.read<BranchProvider>();
    setState(() => _selectedBranchId = branchProvider.selectedBranch?.id ??
        (branchProvider.allBranches.isNotEmpty ? branchProvider.allBranches.first.id : null));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // --- LOGIC ĐỊNH VỊ ---
  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark p = placemarks[0];
        _addressController.text = "${p.street}, ${p.subAdministrativeArea}, ${p.administrativeArea}";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi vị trí: $e"), backgroundColor: AppColors.error));
    } finally {
      setState(() => _isLocating = false);
    }
  }

  // --- LOGIC VOUCHER ---
  Future<void> _selectVoucher() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const VoucherScreen(isSelectionMode: true))
    );

    if (result is VoucherModel) {
      final cartProvider = context.read<CartProvider>();
      final productProvider = context.read<ProductProvider>();

      // 1. Tính subtotal dựa trên những món ĐÃ CHỌN
      double currentSubtotal = 0;
      for (var id in widget.selectedCartItemIds) {
        final item = cartProvider.items[id];
        if (item != null) {
          final product = productProvider.getProductById(item.productId);
          if (product != null) currentSubtotal += product.basePrice * item.quantity;
        }
      }

      // 2. Kiểm tra đơn tối thiểu
      if (currentSubtotal < result.minOrder) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Đơn tối thiểu phải từ ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(result.minOrder)}"),
              backgroundColor: AppColors.error,
            )
        );
        return; // QUAN TRỌNG: Dừng lại, không gán voucher này
      }

      // 3. Nếu là voucher sản phẩm, kiểm tra xem có món đó trong danh sách ĐÃ CHỌN không
      // Trong CheckoutScreen.dart - Sửa hàm _selectVoucher

      if (result.type == VoucherType.product) {
        final cartProvider = context.read<CartProvider>();
        final productProvider = context.read<ProductProvider>(); // Đảm bảo đã có provider này

        bool hasMatch = widget.selectedCartItemIds.any((cartId) {
          final item = cartProvider.items[cartId];
          if (item != null) {
            // SỬA TẠI ĐÂY: Lấy ProductModel từ productId (Document ID)
            final product = productProvider.getProductById(item.productId);

            // So sánh trường 'id' bên trong ProductModel (ví dụ: "prd01")
            // với danh sách của Voucher
            return result.applicableProductIds?.contains(product?.id) ?? false;
          }
          return false;
        });

        if (!hasMatch) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Mã này không áp dụng cho các món bạn đã chọn"),
                backgroundColor: AppColors.error,
              )
          );
          return;
        }
      }

      // 4. Chỉ khi vượt qua hết các kiểm tra trên mới gán voucher vào State
      setState(() => _selectedVoucher = result);
    }
  }

  double _calculateDiscount(double subtotal, double shippingFee, CartProvider cart, ProductProvider productProvider) {
    if (_selectedVoucher == null || subtotal < _selectedVoucher!.minOrder) return 0.0;

    switch (_selectedVoucher!.type) {
      case VoucherType.bill:
        return subtotal * (_selectedVoucher!.discountPercent / 100);
      case VoucherType.shipping:
        return _selectedVoucher!.discountPercent > 0 ? _selectedVoucher!.discountPercent : (shippingFee > 15000 ? 15000 : shippingFee);
      case VoucherType.product:
        double targetPrice = 0.0;
        final productIds = _selectedVoucher!.applicableProductIds ?? [];
        for (var id in widget.selectedCartItemIds) {
          final item = cart.items[id];
          if (item != null && productIds.contains(item.productId)) {
            final product = productProvider.getProductById(item.productId);
            if (product != null) targetPrice += (product.basePrice * item.quantity);
          }
        }
        return targetPrice * (_selectedVoucher!.discountPercent / 100);
      default:
        return 0.0;
    }
  }

  // --- LOGIC ĐẶT HÀNG CHÍNH ---
  Future<void> _handlePlaceOrder() async {
    final cartProvider = context.read<CartProvider>();
    final productProvider = context.read<ProductProvider>();
    final authProvider = context.read<AuthProvider>();
    final orderProvider = context.read<OrderProvider>();

    if (_nameController.text.isEmpty || _phoneController.text.isEmpty || (_deliveryType == 0 && _addressController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng điền đủ thông tin giao hàng")));
      return;
    }

    // 1. Chuẩn bị dữ liệu
    List<Map<String, dynamic>> orderItems = [];
    double subtotal = 0;
    for (var id in widget.selectedCartItemIds) {
      final item = cartProvider.items[id];
      if (item != null) {
        final product = productProvider.getProductById(item.productId);
        if (product != null) {
          subtotal += product.basePrice * item.quantity;
          orderItems.add({
            'productId': item.productId,
            'productName': product.name,
            'quantity': item.quantity,
            'price': product.basePrice,
            'image': product.image,
            'size': item.size,
          });
        }
      }
    }

    double shipping = _deliveryType == 0 ? 15000.0 : 0.0;
    double discount = _calculateDiscount(subtotal, shipping, cartProvider, productProvider);
    double finalTotal = subtotal + shipping - discount;

    String finalAddress = "";
    if (_deliveryType == 0) {
      finalAddress = _addressController.text.trim();
    } else {
      // Tìm branch trong danh sách dựa trên ID đã chọn
      final branchProvider = context.read<BranchProvider>();
      final selectedBranch = branchProvider.allBranches.firstWhere(
            (b) => b.id == _selectedBranchId,
        orElse: () => branchProvider.allBranches.first,
      );
      finalAddress = selectedBranch.name; // Gán tên chi nhánh (VD: Bông Biêng - Phố Huế)
    }

    final newOrder = OrderModel(
      id: "DH${DateTime.now().millisecondsSinceEpoch}",
      userId: authProvider.user?.id ?? 'guest',
      customerName: _nameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      address: finalAddress,
      paymentMethod: _paymentMethod,
      items: orderItems,
      subtotal: subtotal,
      shippingFee: shipping,
      discountAmount: discount,
      totalAmount: finalTotal,
      status: (_paymentMethod == 'cod') ? 'processing' : 'waiting_confirm',
      isPaid: false,
      voucherCode: _selectedVoucher?.code,
    );

    // 2. Xử lý theo phương thức thanh toán
    if (_paymentMethod == 'cod') {
      // Nếu là COD, lưu luôn và hiện thành công
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
      String? result = await orderProvider.placeOrder(newOrder);
      Navigator.pop(context);

      if (result == "success") {
        await cartProvider.removeMultipleItems(widget.selectedCartItemIds);
        _showSuccessDialog(newOrder);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi lưu đơn hàng")));
      }
    }
    else if (_paymentMethod == 'zalopay') {
      // Nếu là ZaloPay, lấy URL trước
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
      String? result = await orderProvider.placeOrder(newOrder);
      Navigator.pop(context);

      if (result != null && result != "success") {
        _openZaloPayApp(result, newOrder);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi kết nối ZaloPay")));
      }
    }
    else if (_paymentMethod == 'banking') {
      // Nếu là Banking, HIỆN QR TRƯỚC, KHÔNG gọi placeOrder ở đây để tránh nhảy trang
      _showBankingQRDialog(finalTotal, newOrder);
    }
  }

  // --- DIALOGS ---
  void _showZaloPayQRDialog(String url, OrderModel order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("ZaloPay Sandbox"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Dùng App ZaloPay Sandbox quét mã"),
            const SizedBox(height: 20),
            Image.network("https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=$url"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await context.read<OrderProvider>().confirmPaid(order);
              await context.read<CartProvider>().removeMultipleItems(widget.selectedCartItemIds);
              Navigator.pop(context);
              _showSuccessDialog(order);
            },
            child: const Text("TÔI ĐÃ THANH TOÁN XONG"),
          )
        ],
      ),
    );
  }

  void _showBankingQRDialog(double amount, OrderModel order) {
    String bankBin = "970422";
    String accountNumber = "0818988187";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Thanh toán VietQR"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
                "https://img.vietqr.io/image/$bankBin-$accountNumber-compact.jpg?amount=${amount.toInt()}&addInfo=${order.id}"
            ),
            const SizedBox(height: 10),
            Text("Nội dung: ${order.id}", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await context.read<OrderProvider>().confirmPaid(order);
              await context.read<CartProvider>().removeMultipleItems(widget.selectedCartItemIds);
              Navigator.pop(context);
              _showSuccessDialog(order);
            },
            child: const Text("ĐÃ CHUYỂN KHOẢN"),
          )
        ],
      ),
    );
  }

  void _showSuccessDialog(OrderModel order) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => OrderSuccessScreen(order: order)),
          (route) => route.isFirst,
    );
  }

  Future<void> _openZaloPayApp(String url, OrderModel order) async {
    final Uri zalopayUri = Uri.parse(url);
    try {
      if (await canLaunchUrl(zalopayUri)) {
        await launchUrl(zalopayUri, mode: LaunchMode.externalApplication);
        _showConfirmAfterRedirectDialog(url, order);
      } else {
        _showZaloPayQRDialog(url, order);
      }
    } catch (e) {
      _showZaloPayQRDialog(url, order);
    }
  }

  void _showConfirmAfterRedirectDialog(String url, OrderModel order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Đang thanh toán"),
        content: const Text("Vui lòng xác nhận sau khi đã thanh toán trên ZaloPay."),
        actions: [
          TextButton(
            onPressed: () async {
              await context.read<OrderProvider>().confirmPaid(order);
              await context.read<CartProvider>().removeMultipleItems(widget.selectedCartItemIds);
              Navigator.pop(context);
              _showSuccessDialog(order);
            },
            child: const Text("XÁC NHẬN ĐÃ THANH TOÁN", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showZaloPayQRDialog(url, order);
            },
            child: const Text("QUÉT QR THAY THẾ"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final productProvider = context.watch<ProductProvider>();
    final branches = context.watch<BranchProvider>().allBranches;

    double subtotal = 0;
    for (var id in widget.selectedCartItemIds) {
      final item = cartProvider.items[id];
      if (item != null) {
        final product = productProvider.getProductById(item.productId);
        if (product != null) subtotal += product.basePrice * item.quantity;
      }
    }

    double shipping = _deliveryType == 0 ? 15000.0 : 0.0;
    double discount = _calculateDiscount(subtotal, shipping, cartProvider, productProvider);
    double finalTotal = subtotal + shipping - discount;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Thanh toán', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryLight, elevation: 0.5, centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                DeliveryMethodSection(selectedType: _deliveryType, onChanged: (val) => setState(() => _deliveryType = val)),
                const SizedBox(height: 12),
                CustomerInfoSection(
                  deliveryType: _deliveryType, nameController: _nameController, phoneController: _phoneController,
                  addressController: _addressController, noteController: _noteController,
                  branches: branches, selectedBranchId: _selectedBranchId,
                  onBranchChanged: (val) => setState(() => _selectedBranchId = val),
                  isLocating: _isLocating, onLocate: _getCurrentLocation,
                ),
                const SizedBox(height: 12),
                OrderItemsSection(selectedIds: widget.selectedCartItemIds),
                const SizedBox(height: 12),
                VoucherSection(selectedVoucher: _selectedVoucher, onTap: _selectVoucher, onRemove: () => setState(() => _selectedVoucher = null)),
                const SizedBox(height: 12),
                PaymentMethodSection(selectedMethod: _paymentMethod, onChanged: (val) => setState(() => _paymentMethod = val)),
                const SizedBox(height: 12),
                PaymentSummarySection(subtotal: subtotal, shippingFee: shipping, discount: discount, total: finalTotal),
              ],
            ),
          ),
          _buildBottomBar(finalTotal),
        ],
      ),
    );
  }

  Widget _buildBottomBar(double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _handlePlaceOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text("ĐẶT HÀNG • ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(total)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        ),
      ),
    );
  }
}