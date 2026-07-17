// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// /// SmartLink Ad Widget
// /// Opens the smartlink URL when tapped
// class SmartLinkAd extends StatelessWidget {
//   final String smartLinkUrl;
//   final Widget? child;
//   final EdgeInsetsGeometry? padding;
//   final EdgeInsetsGeometry? margin;
//
//   const SmartLinkAd({
//     super.key,
//     this.smartLinkUrl =
//         'https://bigotcomet.com/hmr4f43865?key=f1f00a35cf8e26a32e7e8cad972db50d',
//     this.child,
//     this.padding,
//     this.margin,
//   });
//
//   Future<void> _openSmartLink(BuildContext context) async {
//     try {
//       final Uri uri = Uri.parse(smartLinkUrl);
//       if (await canLaunchUrl(uri)) {
//         await launchUrl(
//           uri,
//           mode: kIsWeb
//               ? LaunchMode.externalApplication
//               : LaunchMode.externalApplication,
//         );
//       }
//     } catch (e) {
//       debugPrint('Error opening smartlink: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () => _openSmartLink(context),
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             padding: padding ??
//                 const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   const Color(0xFF6366F1).withOpacity(0.1),
//                   const Color(0xFF8B5CF6).withOpacity(0.1),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: const Color(0xFF6366F1).withOpacity(0.3),
//                 width: 1,
//               ),
//             ),
//             child: child ??
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.open_in_new,
//                       color: const Color(0xFF6366F1),
//                       size: 20,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Sponsored Link',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.8),
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//           ),
//         ),
//       ),
//     );
//   }
// }
