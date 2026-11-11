class MarketplaceItem {
  final String productName;
  final String category;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final String sellerName;
  final String location;
  final String contactNumber;
  final DateTime listedDate;
  final DateTime? availableUntil;
  final String qualityGrade;
  final String description;
  final bool available;

  const MarketplaceItem({
    required this.productName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.sellerName,
    required this.location,
    required this.contactNumber,
    required this.listedDate,
    required this.availableUntil,
    required this.qualityGrade,
    required this.description,
    this.available = true,
  });

  double get totalValue {
    return quantity * pricePerUnit;
  }

  String get priceText {
    return 'R${pricePerUnit.toStringAsFixed(2)} / $unit';
  }

  String get quantityText {
    return '${quantity.toStringAsFixed(1)} $unit';
  }

  String get totalValueText {
    return 'R${totalValue.toStringAsFixed(2)}';
  }

  String get availabilityStatus {
    return available ? 'Available' : 'Sold Out';
  }

  bool get hasAvailableUntilDate {
    return availableUntil != null;
  }

  bool get isExpired {
    if (availableUntil == null) {
      return false;
    }

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final expiry = DateTime(
      availableUntil!.year,
      availableUntil!.month,
      availableUntil!.day,
    );

    return expiry.isBefore(today);
  }

  String formatDate(DateTime? date) {
    if (date == null) {
      return 'Not specified';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String get listedDateText {
    return formatDate(listedDate);
  }

  String get availableUntilText {
    return formatDate(availableUntil);
  }
}