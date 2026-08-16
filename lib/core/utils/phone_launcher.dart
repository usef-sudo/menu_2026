import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

Future<bool> launchPhoneCall(BuildContext context, String phone) async {
  final String digits = phone.replaceAll(RegExp(r"[^\d+]"), "");
  if (digits.isEmpty) {
    return false;
  }
  final Uri uri = Uri(scheme: "tel", path: digits);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
    return true;
  }
  return false;
}
