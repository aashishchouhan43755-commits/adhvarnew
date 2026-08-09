class PaginationModel {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginationModel({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    final currentPage = json['current_page'] ?? 1;
    final totalPages = json['total_pages'] ?? 1;

    return PaginationModel(
      currentPage: currentPage,
      totalPages: totalPages,
      totalItems: json['total_items'] ?? 0,
      pageSize: json['page_size'] ?? 10,
      hasNextPage: json['has_next_page'] ?? (currentPage < totalPages),
      hasPreviousPage: json['has_previous_page'] ?? (currentPage > 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_items': totalItems,
      'page_size': pageSize,
      'has_next_page': hasNextPage,
      'has_previous_page': hasPreviousPage,
    };
  }

  PaginationModel copyWith({
    int? currentPage,
    int? totalPages,
    int? totalItems,
    int? pageSize,
    bool? hasNextPage,
    bool? hasPreviousPage,
  }) {
    return PaginationModel(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      pageSize: pageSize ?? this.pageSize,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
    );
  }

  @override
  String toString() {
    return 'PaginationModel('
        'currentPage: $currentPage, '
        'totalPages: $totalPages, '
        'totalItems: $totalItems'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PaginationModel &&
        other.currentPage == currentPage &&
        other.totalPages == totalPages &&
        other.totalItems == totalItems &&
        other.pageSize == pageSize &&
        other.hasNextPage == hasNextPage &&
        other.hasPreviousPage == hasPreviousPage;
  }

  @override
  int get hashCode {
    return Object.hash(
      currentPage,
      totalPages,
      totalItems,
      pageSize,
      hasNextPage,
      hasPreviousPage,
    );
  }
}
