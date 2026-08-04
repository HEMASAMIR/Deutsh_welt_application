class BookModel {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final double price;
  final String pdfUrl;        // Link to PDF (Google Drive / any URL)
  final String coverImageUrl; // Optional cover image URL
  final List<String> benefits; // Why this book is important
  final int totalPages;
  final bool isAvailable;
  final String adminWhatsApp;  // Admin WhatsApp number for order notifications

  const BookModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.price,
    required this.pdfUrl,
    this.coverImageUrl = '',
    required this.benefits,
    this.totalPages = 0,
    this.isAvailable = true,
    required this.adminWhatsApp,
  });

  BookModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    double? price,
    String? pdfUrl,
    String? coverImageUrl,
    List<String>? benefits,
    int? totalPages,
    bool? isAvailable,
    String? adminWhatsApp,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      price: price ?? this.price,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      benefits: benefits ?? this.benefits,
      totalPages: totalPages ?? this.totalPages,
      isAvailable: isAvailable ?? this.isAvailable,
      adminWhatsApp: adminWhatsApp ?? this.adminWhatsApp,
    );
  }
}
