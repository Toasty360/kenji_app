class settings {
  static bool enableHentai = false;
  static toggleHentai() => enableHentai = !enableHentai;
  static String qualityChoice = "default";
  static String qualityStatus = qualityChoice == "default" ? "High" : "Low";
  static String baseURL = "https://spicy-api.vercel.app/";
}

class currentDownloads {
  static Map<String, bool> downloads = {};
}
