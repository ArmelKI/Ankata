class SotracoLine {
  final String id;
  final String code;
  final String name;
  final int distanceKm;
  final int durationMin;
  final int stopsCount;
  final String serviceHours;
  final String frequency;
  final List<String> stops;
  final List<String> sampleTimes;

  const SotracoLine({
    required this.id,
    required this.code,
    required this.name,
    required this.distanceKm,
    required this.durationMin,
    required this.stopsCount,
    required this.serviceHours,
    required this.frequency,
    required this.stops,
    required this.sampleTimes,
  });
}

class SotracoData {
  static const String city = 'Ouagadougou';
  static const String fareNote =
      'Tarif urbain uniforme (a confirmer, 150-200 FCFA)';

  static const List<SotracoLine> lines = [
    SotracoLine(
      id: 'sotraco_l1',
      code: 'L1',
      name: 'Karpala ↔ Place Naaba Koom',
      distanceKm: 10,
      durationMin: 35,
      stopsCount: 24,
      serviceHours: '05:30 - 20:00',
      frequency: '8-12 min',
      stops: [
        'Karpala',
        'Cite Azimo',
        'Tanghin',
        'Koulouba',
        'Place Naaba Koom',
      ],
      sampleTimes: ['05:30', '05:42', '05:54', '06:06', '06:18'],
    ),
    SotracoLine(
      id: 'sotraco_l2',
      code: 'L2',
      name: '2 Boutiques ↔ Place Naaba Koom',
      distanceKm: 8,
      durationMin: 30,
      stopsCount: 20,
      serviceHours: '05:40 - 20:10',
      frequency: '8-12 min',
      stops: [
        '2 Boutiques',
        'Gounghin',
        'Zone 1',
        'Rond-point Nations Unies',
        'Place Naaba Koom',
      ],
      sampleTimes: ['05:40', '05:52', '06:04', '06:16', '06:28'],
    ),
    SotracoLine(
      id: 'sotraco_l2b',
      code: 'L2B',
      name: 'Balkuy ↔ Place Naaba Koom',
      distanceKm: 18,
      durationMin: 55,
      stopsCount: 39,
      serviceHours: '05:20 - 20:00',
      frequency: '10-15 min',
      stops: [
        'Balkuy',
        'Zone industrielle',
        'Patte d\'oie',
        'Rond-point CNSS',
        'Place Naaba Koom',
      ],
      sampleTimes: ['05:20', '05:35', '05:50', '06:05', '06:20'],
    ),
    SotracoLine(
      id: 'sotraco_l3',
      code: 'L3',
      name: 'Terminus Bissighin ↔ Zones de Ecoles',
      distanceKm: 12,
      durationMin: 40,
      stopsCount: 26,
      serviceHours: '05:50 - 20:30',
      frequency: '10-15 min',
      stops: [
        'Bissighin',
        'Patte d\'oie',
        'Wayalghin',
        'Zones de Ecoles',
      ],
      sampleTimes: [
        '05:50',
        '06:05',
        '06:20',
        '06:35',
        '06:50',
        '07:06',
      ],
    ),
    SotracoLine(
      id: 'sotraco_l6b',
      code: 'L6B',
      name: 'Terminus du Peage ↔ Place Naaba Koom',
      distanceKm: 14,
      durationMin: 48,
      stopsCount: 30,
      serviceHours: '05:10 - 20:30',
      frequency: '6-8 min (pointe)',
      stops: [
        'Peage',
        'Patte d\'oie',
        'Centre-ville',
        'Place Naaba Koom',
      ],
      sampleTimes: [
        '05:10',
        '05:16',
        '05:22',
        '05:28',
        '05:34',
        '05:40',
        '05:46',
        '05:52',
      ],
    ),
  ];

  static List<String> getAllStops() {
    final stops = <String>{};
    for (final line in lines) {
      stops.addAll(line.stops);
    }
    return stops.toList()..sort();
  }

  static SotracoLine? getLineById(String id) {
    for (final line in lines) {
      if (line.id == id) {
        return line;
      }
    }
    return null;
  }

  static List<SotracoLine> findLinesForStops(String fromStop, String toStop) {
    final results = <SotracoLine>[];
    for (final line in lines) {
      final fromIndex = line.stops.indexOf(fromStop);
      final toIndex = line.stops.indexOf(toStop);
      if (fromIndex != -1 && toIndex != -1 && fromIndex < toIndex) {
        results.add(line);
      }
    }
    return results;
  }
}
