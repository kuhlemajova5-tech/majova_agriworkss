class InventoryItem {
  final String itemName;
  final String category;
  final String unit;
  final double quantity;
  final double minimumStockLevel;
  final double unitCost;
  final String supplier;
  final String storageLocation;
  final DateTime? purchaseDate;
  final DateTime? expiryDate;
  final String notes;

  const InventoryItem({
    required this.itemName,
    required this.category,
    required this.unit,
    required this.quantity,
    required this.minimumStockLevel,
    required this.unitCost,
    required this.supplier,
    required this.storageLocation,
    required this.purchaseDate,
    required this.expiryDate,
    this.notes = '',
  });

  bool get isLowStock {
    return quantity <= minimumStockLevel;
  }

  bool get isOutOfStock {
    return quantity <= 0;
  }

  bool get hasExpiryDate {
    return expiryDate != null;
  }

  bool get isExpired {
    if (expiryDate == null) {
      return false;
    }

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final expiry = DateTime(
      expiryDate!.year,
      expiryDate!.month,
      expiryDate!.day,
    );

    return expiry.isBefore(today);
  }

  bool get isExpiringSoon {
    if (expiryDate == null || isExpired) {
      return false;
    }

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final expiry = DateTime(
      expiryDate!.year,
      expiryDate!.month,
      expiryDate!.day,
    );

    final daysRemaining = expiry.difference(today).inDays;

    return daysRemaining <= 30;
  }

  double get totalValue {
    return quantity * unitCost;
  }

  String get quantityText {
    return '${quantity.toStringAsFixed(1)} $unit';
  }

  String get minimumStockText {
    return '${minimumStockLevel.toStringAsFixed(1)} $unit';
  }

  String get unitCostText {
    return 'R${unitCost.toStringAsFixed(2)}';
  }

  String get totalValueText {
    return 'R${totalValue.toStringAsFixed(2)}';
  }

  String get stockStatus {
    if (isOutOfStock) {
      return 'Out of Stock';
    }

    if (isLowStock) {
      return 'Low Stock';
    }

    return 'In Stock';
  }

  String formatDate(DateTime? date) {
    if (date == null) {
      return 'Not recorded';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String get purchaseDateText {
    return formatDate(purchaseDate);
  }

  String get expiryDateText {
    return formatDate(expiryDate);
  }
}