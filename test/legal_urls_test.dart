import "package:flutter_test/flutter_test.dart";
import "package:menu_2026/core/legal/legal_urls.dart";

void main() {
  test("LegalUrls exposes non-empty default placeholders for store setup", () {
    expect(LegalUrls.privacyPolicy, isNotEmpty);
    expect(LegalUrls.termsOfService, isNotEmpty);
    expect(LegalUrls.privacyPolicy, contains("http"));
    expect(LegalUrls.termsOfService, contains("http"));
  });
}
