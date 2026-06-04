import '../models/models.dart';

/// Image presets — keeps mock entries readable vs the React bundle.
abstract final class MockImages {
  /// `fm=jpg` avoids AVIF/WebP codecs some Android emulators decode poorly.
  static const desktop =
      'https://images.unsplash.com/photo-1587202372634-32705e3bf49c?fm=jpg&fit=crop&q=80&w=800';
  static const laptop =
      'https://images.unsplash.com/photo-1603302576837-37561b2e2302?fm=jpg&fit=crop&q=80&w=800';
  static const gpu =
      'https://images.unsplash.com/photo-1591488320449-011701bb6704?fm=jpg&fit=crop&q=80&w=800';
  static const chip =
      'https://images.unsplash.com/photo-1591799264318-7e6ef8ddb7ea?fm=jpg&fit=crop&q=80&w=240';
  static const motherboard =
      'https://images.unsplash.com/photo-1518770660439-4636190af475?fm=jpg&fit=crop&q=80&w=240';
  static const ddr =
      'https://images.unsplash.com/photo-1562976540-1502c2145186?fm=jpg&fit=crop&q=80&w=240';
  static const nvme =
      'https://images.unsplash.com/photo-1597852074816-d933c7d2b988?fm=jpg&fit=crop&q=80&w=240';
  static const psu =
      'https://images.unsplash.com/photo-1587202372775-e229f172b9d7?fm=jpg&fit=crop&q=80&w=240';
  static const chassis =
      'https://images.unsplash.com/photo-1555680202-c86f0e12f086?fm=jpg&fit=crop&q=80&w=240';
}

final List<Product> featuredProducts = [
  Product(
    id: 'p1',
    name: 'Nebula X9 - Creator Pro',
    category: 'Desktops',
    price: 2499.99,
    image: MockImages.desktop,
    specs: ProductSpecs(
      cpu: 'Intel Core i9-14900K',
      gpu: 'NVIDIA RTX 4080 Super',
      ram: '64GB DDR5-6000',
      storage: '2TB NVMe Gen4',
    ),
    benchmarks: ProductBenchmarks(gaming: 95, productivity: 98),
    isNew: true,
  ),
  Product(
    id: 'p2',
    name: 'Blade 16 Gaming Laptop',
    category: 'Laptops',
    price: 1899.99,
    image: MockImages.laptop,
    specs: ProductSpecs(
      cpu: 'AMD Ryzen 9 7945HX',
      gpu: 'NVIDIA RTX 4070',
      ram: '32GB DDR5',
      storage: '1TB NVMe',
      display: '16" QHD+ 240Hz Mini-LED',
    ),
    benchmarks: ProductBenchmarks(gaming: 88, productivity: 90),
    isDeal: true,
  ),
];

/// Build-of-the-month product (not shown in featured grid — same as React Home).
final Product buildOfTheMonthProduct = Product(
  id: 'botm',
  name: 'Neon Phantom (Build of the Month)',
  category: 'Desktops',
  price: 3299,
  image: MockImages.desktop,
  specs: ProductSpecs(
    cpu: 'AMD Ryzen 7 7800X3D',
    gpu: 'NVIDIA RTX 4080 Super',
    ram: '32GB DDR5-6000',
    storage: '2TB NVMe Gen4',
  ),
  benchmarks: ProductBenchmarks(gaming: 97, productivity: 94),
  isNew: true,
);

/// All catalog products keyed by id (featured + BOTM).
List<Product> get allCatalogProducts => [
  ...featuredProducts,
  buildOfTheMonthProduct,
];

class HeroSlideSpec {
  const HeroSlideSpec({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.isCyanAccent,
  });

  final int id;
  final String title;
  final String subtitle;
  final String image;
  final bool isCyanAccent;
}

final List<HeroSlideSpec> heroSlides = [
  HeroSlideSpec(
    id: 1,
    title: 'PROJECT ZERO',
    subtitle: 'CABLE-FREE AESTHETICS',
    image: MockImages.desktop,
    isCyanAccent: true,
  ),
  HeroSlideSpec(
    id: 2,
    title: 'RTX 4090',
    subtitle: 'BEYOND FAST',
    image: MockImages.gpu,
    isCyanAccent: false,
  ),
];

class BrandMarqueeSpec {
  const BrandMarqueeSpec({required this.name, required this.slug});

  /// Uppercase label beside the logo.
  final String name;

  /// Simple Icons slug (see npm `simple-icons`): e.g. `asus`, `msi`, `logitechg`.
  final String slug;
}

final List<BrandMarqueeSpec> marqueeBrands = [
  BrandMarqueeSpec(name: 'ASUS', slug: 'asus'),
  BrandMarqueeSpec(name: 'RAZER', slug: 'razer'),
  BrandMarqueeSpec(name: 'CORSAIR', slug: 'corsair'),
  BrandMarqueeSpec(name: 'MSI', slug: 'msibusiness'),
  BrandMarqueeSpec(name: 'ALIENWARE', slug: 'alienware'),
  BrandMarqueeSpec(name: 'LOGITECH G', slug: 'logitechg'),
  BrandMarqueeSpec(name: 'STEELSERIES', slug: 'steelseries'),
  BrandMarqueeSpec(name: 'NVIDIA', slug: 'nvidia'),
  BrandMarqueeSpec(name: 'AMD', slug: 'amd'),
  BrandMarqueeSpec(name: 'INTEL', slug: 'intel'),
  BrandMarqueeSpec(name: 'HYPERX', slug: 'hyperx'),
  BrandMarqueeSpec(name: 'ACER', slug: 'acer'),
  BrandMarqueeSpec(name: 'DELL', slug: 'dell'),
  BrandMarqueeSpec(name: 'HP', slug: 'hp'),
  BrandMarqueeSpec(name: 'LENOVO', slug: 'lenovo'),
];

class CategorySpec {
  const CategorySpec({required this.id, required this.label});
  final String id;
  final String label;
}

final categoryTiles = [
  CategorySpec(id: 'laptops', label: 'Laptops'),
  CategorySpec(id: 'desktops', label: 'Desktops'),
  CategorySpec(id: 'components', label: 'Components'),
  CategorySpec(id: 'peripherals', label: 'Peripherals'),
  CategorySpec(id: 'monitors', label: 'Monitors'),
  CategorySpec(id: 'networking', label: 'Networking'),
];

class BuilderCatalog {
  static final cpus = [
    CpuPart(
      id: 'cpu1',
      partType: 'cpu',
      name: 'AMD Ryzen 7 7800X3D',
      brand: 'AMD',
      price: 399.99,
      socket: 'AM5',
      tdp: 120,
      cores: 8,
      threads: 16,
      speed: '4.2 GHz',
      image: MockImages.chip,
    ),
    CpuPart(
      id: 'cpu2',
      partType: 'cpu',
      name: 'Intel Core i7-14700K',
      brand: 'Intel',
      price: 409.99,
      socket: 'LGA1700',
      tdp: 253,
      cores: 20,
      threads: 28,
      speed: '3.4 GHz',
      image: MockImages.chip,
    ),
    CpuPart(
      id: 'cpu3',
      partType: 'cpu',
      name: 'AMD Ryzen 5 7600X',
      brand: 'AMD',
      price: 229.99,
      socket: 'AM5',
      tdp: 105,
      cores: 6,
      threads: 12,
      speed: '4.7 GHz',
      image: MockImages.chip,
    ),
    CpuPart(
      id: 'cpu4',
      partType: 'cpu',
      name: 'Intel Core i5-13600K',
      brand: 'Intel',
      price: 289.99,
      socket: 'LGA1700',
      tdp: 181,
      cores: 14,
      threads: 20,
      speed: '3.5 GHz',
      image: MockImages.chip,
    ),
  ];

  static final motherboards = [
    MotherboardPart(
      id: 'mb1',
      partType: 'motherboard',
      name: 'ASUS ROG Strix X670E-E',
      brand: 'ASUS',
      price: 479.99,
      socket: 'AM5',
      ramType: 'DDR5',
      formFactor: 'ATX',
      image: MockImages.motherboard,
    ),
    MotherboardPart(
      id: 'mb2',
      partType: 'motherboard',
      name: 'MSI MAG B650 Tomahawk',
      brand: 'MSI',
      price: 219.99,
      socket: 'AM5',
      ramType: 'DDR5',
      formFactor: 'ATX',
      image: MockImages.motherboard,
    ),
    MotherboardPart(
      id: 'mb3',
      partType: 'motherboard',
      name: 'Gigabyte Z790 AORUS ELITE',
      brand: 'Gigabyte',
      price: 259.99,
      socket: 'LGA1700',
      ramType: 'DDR5',
      formFactor: 'ATX',
      image: MockImages.motherboard,
    ),
    MotherboardPart(
      id: 'mb4',
      partType: 'motherboard',
      name: 'ASRock B760M Pro RS',
      brand: 'ASRock',
      price: 129.99,
      socket: 'LGA1700',
      ramType: 'DDR4',
      formFactor: 'mATX',
      image: MockImages.motherboard,
    ),
  ];

  static final ram = [
    RamPart(
      id: 'ram1',
      partType: 'ram',
      name: 'Corsair Vengeance RGB 32GB',
      brand: 'Corsair',
      price: 119.99,
      ramType: 'DDR5',
      capacity: '32GB',
      speed: '6000MHz',
      image: MockImages.ddr,
    ),
    RamPart(
      id: 'ram2',
      partType: 'ram',
      name: 'G.Skill Trident Z5 Neo 64GB',
      brand: 'G.Skill',
      price: 214.99,
      ramType: 'DDR5',
      capacity: '64GB',
      speed: '6000MHz',
      image: MockImages.ddr,
    ),
    RamPart(
      id: 'ram3',
      partType: 'ram',
      name: 'TeamGroup T-Force Delta 32GB',
      brand: 'TeamGroup',
      price: 74.99,
      ramType: 'DDR4',
      capacity: '32GB',
      speed: '3600MHz',
      image: MockImages.ddr,
    ),
  ];

  static final gpus = [
    GpuPart(
      id: 'gpu1',
      partType: 'gpu',
      name: 'NVIDIA GeForce RTX 4090',
      brand: 'NVIDIA',
      price: 1599.99,
      tdp: 450,
      vram: '24GB GDDR6X',
      chipset: 'RTX 4090',
      image: MockImages.gpu,
    ),
    GpuPart(
      id: 'gpu2',
      partType: 'gpu',
      name: 'ASUS TUF RTX 4070 Ti Super',
      brand: 'ASUS',
      price: 799.99,
      tdp: 285,
      vram: '16GB GDDR6X',
      chipset: 'RTX 4070 Ti Super',
      image: MockImages.gpu,
    ),
    GpuPart(
      id: 'gpu3',
      partType: 'gpu',
      name: 'Sapphire Nitro+ RX 7900 XTX',
      brand: 'Sapphire',
      price: 999.99,
      tdp: 355,
      vram: '24GB GDDR6',
      chipset: 'RX 7900 XTX',
      image: MockImages.gpu,
    ),
    GpuPart(
      id: 'gpu4',
      partType: 'gpu',
      name: 'MSI Ventus 2X RTX 4060',
      brand: 'MSI',
      price: 299.99,
      tdp: 115,
      vram: '8GB GDDR6',
      chipset: 'RTX 4060',
      image: MockImages.gpu,
    ),
  ];

  static final storage = [
    StoragePart(
      id: 'sto1',
      partType: 'storage',
      name: 'Samsung 990 PRO 2TB',
      brand: 'Samsung',
      price: 169.99,
      capacity: '2TB',
      slotInterface: 'PCIe 4.0 x4',
      partFormFactor: 'M.2 2280',
      image: MockImages.nvme,
    ),
    StoragePart(
      id: 'sto2',
      partType: 'storage',
      name: 'WD Black SN850X 1TB',
      brand: 'Western Digital',
      price: 84.99,
      capacity: '1TB',
      slotInterface: 'PCIe 4.0 x4',
      partFormFactor: 'M.2 2280',
      image: MockImages.nvme,
    ),
    StoragePart(
      id: 'sto3',
      partType: 'storage',
      name: 'Crucial MX500 2TB',
      brand: 'Crucial',
      price: 109.99,
      capacity: '2TB',
      slotInterface: 'SATA III',
      partFormFactor: '2.5"',
      image: MockImages.nvme,
    ),
  ];

  static final psus = [
    PsuPart(
      id: 'psu1',
      partType: 'psu',
      name: 'Corsair RM1000x',
      brand: 'Corsair',
      price: 189.99,
      wattage: 1000,
      efficiency: '80+ Gold',
      modular: 'Full',
      image: MockImages.psu,
    ),
    PsuPart(
      id: 'psu2',
      partType: 'psu',
      name: 'EVGA SuperNOVA 850 G6',
      brand: 'EVGA',
      price: 139.99,
      wattage: 850,
      efficiency: '80+ Gold',
      modular: 'Full',
      image: MockImages.psu,
    ),
    PsuPart(
      id: 'psu3',
      partType: 'psu',
      name: 'Thermaltake Smart 600W',
      brand: 'Thermaltake',
      price: 44.99,
      wattage: 600,
      efficiency: '80+ White',
      modular: 'None',
      image: MockImages.psu,
    ),
  ];

  static final cases = [
    CasePart(
      id: 'case1',
      partType: 'case',
      name: 'NZXT H9 Flow',
      brand: 'NZXT',
      price: 159.99,
      formFactors: const ['ATX', 'mATX', 'ITX'],
      color: 'Black',
      image: MockImages.chassis,
    ),
    CasePart(
      id: 'case2',
      partType: 'case',
      name: 'Lian Li O11 Dynamic EVO',
      brand: 'Lian Li',
      price: 149.99,
      formFactors: const ['ATX', 'mATX', 'ITX'],
      color: 'White',
      image: MockImages.chassis,
    ),
    CasePart(
      id: 'case3',
      partType: 'case',
      name: 'Fractal Design Pop Mini Air',
      brand: 'Fractal Design',
      price: 89.99,
      formFactors: const ['mATX', 'ITX'],
      color: 'Black',
      image: MockImages.chassis,
    ),
  ];
}

/// Flat builder inventory for search (matches React `Search.tsx`).
List<NexusBuilderPart> get allBuilderParts => [
  ...BuilderCatalog.cpus,
  ...BuilderCatalog.motherboards,
  ...BuilderCatalog.ram,
  ...BuilderCatalog.gpus,
  ...BuilderCatalog.storage,
  ...BuilderCatalog.psus,
  ...BuilderCatalog.cases,
];

/// Checkout history for Orders / receipts (paired with `supporting_screens.dart`).
final Map<String, DetailedOrderMock> mockOrderCatalog = {
  'NX-9021': DetailedOrderMock(
    summary: OrderSummary(
      id: 'NX-9021',
      date: '2026-05-18',
      total: 2649.12,
      status: OrderStatus.delivered,
      itemCount: 2,
    ),
    carrier: 'NeoShip Apex',
    etaNote: 'Signed at kiosk · Building A',
    lines: [
      OrderLineItem(
        title: 'Nebula X9 — Creator Pro (64GB / 2TB)',
        qty: 1,
        unitPrice: 2499.99,
      ),
      OrderLineItem(
        title: 'White-glove cabling install',
        qty: 1,
        unitPrice: 149.99,
      ),
    ],
    trackingHints: [
      'Picked Aurora DC',
      'Arrived Nexus Central Hub',
      'Out for delivery',
      'Delivered',
    ],
  ),
  'NX-9014': DetailedOrderMock(
    summary: OrderSummary(
      id: 'NX-9014',
      date: '2026-05-02',
      total: 1899.99,
      status: OrderStatus.shipped,
      itemCount: 1,
    ),
    carrier: 'NeoShip Apex',
    etaNote: 'Arriving Tue · before 17:00',
    lines: [
      OrderLineItem(
        title: 'Blade 16 Gaming Laptop',
        qty: 1,
        unitPrice: 1899.99,
      ),
    ],
    trackingHints: [
      'Packed Stellar Wharf',
      'Departed distro center',
      'In transit · regional hub',
    ],
  ),
  'NX-8883': DetailedOrderMock(
    summary: OrderSummary(
      id: 'NX-8883',
      date: '2026-04-11',
      total: 512.46,
      status: OrderStatus.processing,
      itemCount: 3,
    ),
    carrier: 'Same-day courier',
    etaNote: 'Slot reserved · Thu AM',
    lines: [
      OrderLineItem(
        title: 'CableMod Pro kit bundle',
        qty: 1,
        unitPrice: 119.99,
      ),
      OrderLineItem(
        title: '32" QD-OLED monitor arm',
        qty: 2,
        unitPrice: 196.235,
      ),
      OrderLineItem(title: 'NexusCare thermal repaste', qty: 1, unitPrice: 0),
    ],
    trackingHints: ['Parts allocated', 'Bench queue #4', 'Awaiting QA'],
  ),
};

List<OrderSummary> listMockOrdersByDate() =>
    [...mockOrderCatalog.values.map((d) => d.summary)]
      ..sort((a, b) => b.date.compareTo(a.date));

DetailedOrderMock? mockOrderDetailById(String? id) {
  if (id == null || id.isEmpty) return null;
  return mockOrderCatalog[id];
}
