import 'package:barcode_widget/barcode_widget.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../model/pasien.dart';
import '../model/kunjungan.dart';

class PdfHelper {
  /// =========================================================
  /// CETAK KARTU PASIEN DENGAN QR CODE + ALAMAT KLINIK
  /// =========================================================
  static Future<void> cetakKartuPasien(Pasien p) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(250, 160), // ukuran kartu
        build: (context) {
          return _buildKartuPasien(p);
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  /// ============================
  ///  WIDGET KARTU PASIEN (FULL)
  /// ============================
  static pw.Widget _buildKartuPasien(Pasien p) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // ============================
          // HEADER KLINIK
          // ============================
          pw.Center(
            child: pw.Text(
              "KLINIK TONG FANG",
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ),

          pw.Center(
            child: pw.Text(
              "Jl. Kramat Raya No.98, RT.2/RW.9, Kwitang, Senen,\n"
              "Kota Jakarta Pusat, DKI Jakarta 10450",
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
            ),
          ),

          pw.SizedBox(height: 6),
          pw.Divider(),
          pw.SizedBox(height: 6),

          // ============================
          // DATA PASIEN + QR CODE
          // ============================
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Kolom Data Pasien
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _row("No. RM", p.nomorRm),
                    _row("Nama", p.nama),
                    _row("Tgl Lahir", p.tanggalLahir),
                    _row("Telepon", p.nomorTelepon),
                  ],
                ),
              ),

              pw.SizedBox(width: 8),

              // QR Code di pojok kanan bawah
              pw.Align(
                alignment: pw.Alignment.bottomRight,
                child: pw.Container(
                  width: 45,
                  height: 45,
                  child: pw.BarcodeWidget(
                    barcode: Barcode.qrCode(),
                    data: p.nomorRm,
                    drawText: false,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Baris label: value kecil untuk kartu
  static pw.Widget _row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 55,
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 9)),
          ),
        ],
      ),
    );
  }

  /// =========================================================
  /// CETAK RESEP
  /// =========================================================
  static Future<void> cetakResep(Kunjungan k) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "RESEP DOKTER",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.Text("Klinik Tong Fang"),
              pw.Divider(),
              pw.SizedBox(height: 8),

              _row("Tanggal", k.tanggal),
              _row("No. RM", k.nomorRm),
              _row("Nama Pasien", k.namaPasien),
              _row("Poli", k.poli),
              _row("Dokter", k.dokter),
              pw.SizedBox(height: 12),

              pw.Text(
                "Diagnosa:",
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(k.diagnosa),
              pw.SizedBox(height: 12),

              pw.Text(
                "Resep Obat:",
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(k.resep),

              pw.Spacer(),

              // TTD Dokter
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("Dokter"),
                    pw.SizedBox(height: 24),
                    pw.Text(
                      k.dokter,
                      style: pw.TextStyle(
                        fontSize: 12,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }
}
