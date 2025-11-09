import 'package:flutter/material.dart';
import '../../models/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String selectedSize = 'M';
  double extraCost = 0;

  @override
  Widget build(BuildContext context) {
    final basePrice = widget.product.basePrice + extraCost;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(widget.product.image, height: 200),
            const SizedBox(height: 12),
            Text(widget.product.description),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Size:'),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('M'),
                  selected: selectedSize == 'M',
                  onSelected: (_) {
                    setState(() {
                      selectedSize = 'M';
                      extraCost = 0;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('L (+10k)'),
                  selected: selectedSize == 'L',
                  onSelected: (_) {
                    setState(() {
                      selectedSize = 'L';
                      extraCost = 10000;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Giá: ${basePrice.toStringAsFixed(0)} đ',
              style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // TODO: thêm vào giỏ hàng ở đây
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Thêm vào giỏ hàng'),
            ),
          ],
        ),
      ),
    );
  }
}
