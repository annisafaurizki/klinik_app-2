import 'package:klinik_app/app/constants/app_image.dart';

class Bacaan {
  final String judul;
  final String deskripsi;
  final String gambar;
  final String link;

  Bacaan({
    required this.judul,
    required this.deskripsi,
    required this.gambar,
    required this.link,
  });
}

final List<Bacaan> bacaanList = [
  Bacaan(
    judul: "Panduan Kesehatan Jantung",
    deskripsi: "Tips menjaga kesehatan jantung dan pola hidup sehat.",
    gambar: AppImage.kBook1,
    link:
        "https://www.who.int/news-room/fact-sheets/detail/cardiovascular-diseases-(cvds)",
  ),
  Bacaan(
    judul: "Gizi Seimbang",
    deskripsi: "Panduan nutrisi untuk kehidupan yang lebih sehat.",
    gambar: AppImage.kBook2,
    link: "https://www.who.int/news-room/fact-sheets/detail/healthy-diet",
  ),
  Bacaan(
    judul: "Manajemen Stress",
    deskripsi: "Cara mengelola stress untuk kesehatan mental.",
    gambar: AppImage.kBook3,
    link: "https://www.who.int/news-room/questions-and-answers/item/stress",
  ),
];
