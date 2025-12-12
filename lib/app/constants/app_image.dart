class AppImage {
  static const String _basePath = 'assets/images';

  static String _imagePath(String fileName) => '$_basePath/$fileName';

  //image
  static final kLogoPNG = _imagePath('logo.png');
  static final kSplashPNG = _imagePath('splash.jpg');
  static final kBGLogin = _imagePath('bg_login.png');
}
