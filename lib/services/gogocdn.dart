// import 'package:crypto/crypto.dart';
// import 'package:html/parser.dart' show parse;
// import 'package:html/dom.dart';

// Future<String> generateEncryptedAjaxParams(Document document, String id) async {
//   final encryptedKey =
//       CryptoJS.AES.encrypt(id, keys['key']!, iv: keys['iv']!).base64;
//   final scriptValue = document
//           .querySelector("script[data-name='episode']")
//           ?.attributes['data-value'] ??
//       '';
//   final decryptedToken = CryptoJS.AES
//       .decrypt(scriptValue, keys['key']!, iv: keys['iv']!)
//       .toString(CryptoJS.enc.Utf8);

//   return 'id=$encryptedKey&alias=$id&$decryptedToken';
// }
