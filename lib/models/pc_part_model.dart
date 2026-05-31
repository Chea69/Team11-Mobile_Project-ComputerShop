enum PcPartType { cpu, motherboard, ram, gpu, storage, psu, pcCase }

extension PcPartTypeLabel on PcPartType {
  String get label {
    switch (this) {
      case PcPartType.cpu:
        return 'CPU';
      case PcPartType.motherboard:
        return 'Motherboard';
      case PcPartType.ram:
        return 'RAM';
      case PcPartType.gpu:
        return 'GPU';
      case PcPartType.storage:
        return 'Storage';
      case PcPartType.psu:
        return 'PSU';
      case PcPartType.pcCase:
        return 'Case';
    }
  }
}

class PcPartModel {
  const PcPartModel({
    required this.id,
    required this.type,
    required this.name,
    required this.brand,
    required this.price,
    this.socket,
    this.ramType,
    this.wattage,
    this.tdp,
  });

  final String id;
  final PcPartType type;
  final String name;
  final String brand;
  final double price;
  final String? socket;
  final String? ramType;
  final int? wattage;
  final int? tdp;
}
