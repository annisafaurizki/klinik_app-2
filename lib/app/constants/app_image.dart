class AppImage {
  static const String _basePath = 'assets/images';

  static String _imagePath(String fileName) => '$_basePath/$fileName';

  //image
  static final kLogoPNG = _imagePath('logo.png');
  static final kSplashPNG = _imagePath('splash.jpg');
  static final kBGLogin = _imagePath('bg_login.png');
  static final kHeartBeat = _imagePath('HeartBeat.png');
  static final kHelp = _imagePath('help.png');
  static final kBook1 = _imagePath('book1.jpg');
  static final kBook2 = _imagePath('book2.jpg');
  static final kBook3 = _imagePath('book3.jpg');
}
