// Hàm bỏ dấu tiếng Việt: "Trà Sữa" -> "tra sua"
// String removeDiacritics(String str) {
//   var withDia = 'áàảãạăắằẳẵặâấầẩẫậéèẻẽẹêếềểễệíìỉĩịóòỏõọôốồổỗộơớờởỡợúùủũụưứừửữựýỳỷỹỵđÁÀẢÃẠĂẮẰẲẴẶÂẤẦẨẪẬÉÈẺẼẸÊẾỀỂỄỆÍÌỈĨỊÓÒỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢÚÙỦŨỤƯỨỪỬỮỰÝỲỶỸỴĐ';
//   var withoutDia = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyydAAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYD';
//   for (int i = 0; i < withDia.length; i++) {
//     str = str.replaceAll(withDia[i], withoutDia[i]);
//   }
//   return str.toLowerCase();
// }

String removeDiacritics(String str) {
  var result = str.toLowerCase();

  result = result.replaceAll(RegExp(r'[áàảãạăắằẳẵặâấầẩẫậ]'), 'a');
  result = result.replaceAll(RegExp(r'[éèẻẽẹêếềểễệ]'), 'e');
  result = result.replaceAll(RegExp(r'[íìỉĩị]'), 'i');
  result = result.replaceAll(RegExp(r'[óòỏõọôốồổỗộơớờởỡợ]'), 'o');
  result = result.replaceAll(RegExp(r'[úùủũụưứừửữự]'), 'u');
  result = result.replaceAll(RegExp(r'[ýỳỷỹỵ]'), 'y');
  result = result.replaceAll(RegExp(r'đ'), 'd');

  return result;
}