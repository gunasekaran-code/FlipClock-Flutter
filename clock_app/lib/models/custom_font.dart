/// A user-imported .ttf / .otf font that has been registered with the
/// Flutter engine under [familyName].
///
/// On mobile/desktop the font bytes live in a file under app storage
/// ([filePath]) — efficient, and keeps SharedPreferences small. On web
/// there is no filesystem, so the bytes are embedded directly as
/// [bytesBase64] instead; exactly one of the two is populated.
class CustomFont {
  final String familyName;
  final String displayName;
  final String filePath; // empty when the font is stored as bytesBase64
  final String? bytesBase64;

  const CustomFont({
    required this.familyName,
    required this.displayName,
    required this.filePath,
    this.bytesBase64,
  });

  Map<String, dynamic> toJson() => {
        'familyName': familyName,
        'displayName': displayName,
        'filePath': filePath,
        if (bytesBase64 != null) 'bytesBase64': bytesBase64,
      };

  factory CustomFont.fromJson(Map<String, dynamic> json) => CustomFont(
        familyName: json['familyName'] as String,
        displayName: json['displayName'] as String,
        filePath: json['filePath'] as String? ?? '',
        bytesBase64: json['bytesBase64'] as String?,
      );
}
