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
    judul: "Essentials of the U.S. Health Care System",
    deskripsi:
        "Buku ini membahas sistem pelayanan kesehatan di Amerika Serikat, termasuk struktur, kebijakan, pembiayaan, dan tantangan dalam dunia kesehatan.",
    gambar: "assets/images/book1.jpg",
    link:
        "https://www.elsevier.com/books/essentials-of-the-us-health-care-system",
  ),
  Bacaan(
    judul: "Gray’s Atlas of Anatomy (2nd Edition)",
    deskripsi:
        "Atlas anatomi terkenal yang menampilkan ilustrasi detail tubuh manusia, mencakup sistem organ, pembuluh darah, dan struktur anatomi penting.",
    gambar: "assets/images/book2.jpg",
    link: "https://www.elsevier.com/books/grays-atlas-of-anatomy",
  ),
  Bacaan(
    judul: "Netter’s Clinical Anatomy (5th Edition)",
    deskripsi:
        "Panduan anatomi klinis dengan ilustrasi khas Netter, membantu memahami hubungan struktur tubuh dengan praktik medis.",
    gambar: "assets/images/book3.jpg",
    link: "https://www.elsevier.com/books/netters-clinical-anatomy",
  ),
];
