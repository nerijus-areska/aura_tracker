class MorningCheckin {
  final String id;
  final DateTime date;
  final double sleepDuration; // hours
  final int sleepQuality; // 1-6

  MorningCheckin({
    required this.id,
    required this.date,
    required this.sleepDuration,
    required this.sleepQuality,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'sleepDuration': sleepDuration,
        'sleepQuality': sleepQuality,
      };

  factory MorningCheckin.fromJson(Map<String, dynamic> json) => MorningCheckin(
        id: json['id'],
        date: DateTime.parse(json['date']),
        sleepDuration: (json['sleepDuration'] as num).toDouble(),
        sleepQuality: json['sleepQuality'],
      );
}

class EveningCheckin {
  final String id;
  final DateTime date;
  final int stress; // 1-6
  final int hydration; // 1-6
  final int caffeine; // 1-3
  final int screenTime; // 1-6
  final String exercise; // none, light, moderate, intense
  final int alcohol; // 0, 1, 2 (0=none, 1=one drink, 2=two+)
  final int mealsSkipped; // 0, 1, 2
  final String sunExposure; // none, little, medium, high
  final String? notes;

  EveningCheckin({
    required this.id,
    required this.date,
    required this.stress,
    required this.hydration,
    required this.caffeine,
    required this.screenTime,
    required this.exercise,
    this.alcohol = 0,
    this.mealsSkipped = 0,
    this.sunExposure = 'none',
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'stress': stress,
        'hydration': hydration,
        'caffeine': caffeine,
        'screenTime': screenTime,
        'exercise': exercise,
        'alcohol': alcohol,
        'mealsSkipped': mealsSkipped,
        'sunExposure': sunExposure,
        'notes': notes,
      };

  factory EveningCheckin.fromJson(Map<String, dynamic> json) => EveningCheckin(
        id: json['id'],
        date: DateTime.parse(json['date']),
        stress: json['stress'],
        hydration: json['hydration'],
        caffeine: json['caffeine'],
        screenTime: json['screenTime'],
        exercise: json['exercise'],
        alcohol: json['alcohol'] ?? 0,
        mealsSkipped: json['mealsSkipped'] ?? 0,
        sunExposure: json['sunExposure'] ?? 'none',
        notes: json['notes'],
      );
}

class Episode {
  final String id;
  final DateTime date;
  final int menstrualCycleDay;
  final int stress; // 1-6 (legacy, kept for backward compat)
  final int hydration; // 1-6 (legacy, kept for backward compat)
  final List<String> visualAuraTypes;
  final String whichEye; // left, right, both, unsure
  final int painSeverity; // 1-6
  final String painLocation;
  final int? painDuration; // minutes
  final DateTime? auraStartTime;
  final int? auraDuration; // minutes
  final DateTime? headacheStartTime;
  final String? location; // home, work, transit, outdoors, other
  final String? notes;
  // Second day recovery
  bool hasSecondDayLog;
  int? functionality; // 1-6 (legacy)
  String? recoveryStatus; // fully_recovered, mostly_recovered, still_affected, worse
  List<String>? lingeringSymptoms;
  String? functionalImpact; // yes, partially, no
  String? whatHelped; // legacy
  String? secondDayNotes;

  Episode({
    required this.id,
    required this.date,
    this.menstrualCycleDay = 0,
    this.stress = 0,
    this.hydration = 0,
    this.visualAuraTypes = const [],
    this.whichEye = 'unsure',
    this.painSeverity = 0,
    this.painLocation = '',
    this.painDuration,
    this.auraStartTime,
    this.auraDuration,
    this.headacheStartTime,
    this.location,
    this.notes,
    this.hasSecondDayLog = false,
    this.functionality,
    this.recoveryStatus,
    this.lingeringSymptoms,
    this.functionalImpact,
    this.whatHelped,
    this.secondDayNotes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'menstrualCycleDay': menstrualCycleDay,
        'visualAuraTypes': visualAuraTypes,
        'whichEye': whichEye,
        'painSeverity': painSeverity,
        'painLocation': painLocation,
        'painDuration': painDuration,
        'auraStartTime': auraStartTime?.toIso8601String(),
        'auraDuration': auraDuration,
        'headacheStartTime': headacheStartTime?.toIso8601String(),
        'location': location,
        'notes': notes,
        'hasSecondDayLog': hasSecondDayLog,
        'functionality': functionality,
        'recoveryStatus': recoveryStatus,
        'lingeringSymptoms': lingeringSymptoms,
        'functionalImpact': functionalImpact,
        'whatHelped': whatHelped,
        'secondDayNotes': secondDayNotes,
      };

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
        id: json['id'],
        date: DateTime.parse(json['date']),
        menstrualCycleDay: json['menstrualCycleDay'] ?? 0,
        stress: json['stress'] ?? 0,
        hydration: json['hydration'] ?? 0,
        visualAuraTypes: json['visualAuraTypes'] != null
            ? List<String>.from(json['visualAuraTypes'])
            : (json['visualAuraType'] != null ? [json['visualAuraType'] as String] : []),
        whichEye: json['whichEye'] ?? 'unsure',
        painSeverity: json['painSeverity'] ?? 0,
        painLocation: json['painLocation'] ?? '',
        painDuration: json['painDuration'],
        auraStartTime: json['auraStartTime'] != null
            ? DateTime.parse(json['auraStartTime'])
            : null,
        auraDuration: json['auraDuration'],
        headacheStartTime: json['headacheStartTime'] != null
            ? DateTime.parse(json['headacheStartTime'])
            : null,
        location: json['location'],
        notes: json['notes'],
        hasSecondDayLog: json['hasSecondDayLog'] ?? false,
        functionality: json['functionality'],
        recoveryStatus: json['recoveryStatus'],
        lingeringSymptoms: json['lingeringSymptoms'] != null
            ? List<String>.from(json['lingeringSymptoms'])
            : null,
        functionalImpact: json['functionalImpact'],
        whatHelped: json['whatHelped'],
        secondDayNotes: json['secondDayNotes'],
      );
}

class SecondDayLog {
  final String id;
  final DateTime date;
  final String recoveryStatus; // fully_recovered, mostly_recovered, still_affected, worse
  final List<String> lingeringSymptoms;
  final String? functionalImpact; // yes, partially, no
  final String? notes;

  SecondDayLog({
    required this.id,
    required this.date,
    required this.recoveryStatus,
    this.lingeringSymptoms = const [],
    this.functionalImpact,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'recoveryStatus': recoveryStatus,
        'lingeringSymptoms': lingeringSymptoms,
        'functionalImpact': functionalImpact,
        'notes': notes,
      };

  factory SecondDayLog.fromJson(Map<String, dynamic> json) => SecondDayLog(
        id: json['id'],
        date: DateTime.parse(json['date']),
        recoveryStatus: json['recoveryStatus'],
        lingeringSymptoms: json['lingeringSymptoms'] != null
            ? List<String>.from(json['lingeringSymptoms'])
            : [],
        functionalImpact: json['functionalImpact'],
        notes: json['notes'],
      );
}

// Constants
class AuraTypes {
  static const List<Map<String, String>> options = [
    {
      'id': 'zigzag',
      'label': 'Zigzag Lines',
      'desc': 'Jagged, shimmering lines',
      'icon': '⚡',
    },
    {
      'id': 'scotoma',
      'label': 'Blind Spot',
      'desc': 'Dark or blank area in vision',
      'icon': '◐',
    },
    {
      'id': 'scintillating',
      'label': 'Scintillating Scotoma',
      'desc': 'Flickering arc of light',
      'icon': '✧',
    },
    {
      'id': 'tunnel',
      'label': 'Tunnel Vision',
      'desc': 'Loss of peripheral vision',
      'icon': '◎',
    },
    {
      'id': 'kaleidoscope',
      'label': 'Kaleidoscope',
      'desc': 'Fractal or mosaic patterns',
      'icon': '❋',
    },
    {
      'id': 'blurring',
      'label': 'Blurring / Haze',
      'desc': 'General visual blurring',
      'icon': '○',
    },
  ];
}

class PainLocations {
  static const List<Map<String, String>> options = [
    {'id': 'left', 'label': 'Left Side'},
    {'id': 'right', 'label': 'Right Side'},
    {'id': 'both', 'label': 'Both Sides'},
    {'id': 'front', 'label': 'Front'},
    {'id': 'back', 'label': 'Back'},
  ];
}

class LingeringSymptoms {
  static const List<String> options = [
    'Brain fog',
    'Fatigue',
    'Neck/shoulder stiffness',
    'Residual light sensitivity',
    'Mood change',
    'Visual disturbance still present',
    'Mild headache',
    'Nausea',
  ];
}

class ExerciseLevels {
  static const List<Map<String, String>> options = [
    {'id': 'none', 'label': 'None', 'icon': '🪑'},
    {'id': 'light', 'label': 'Light', 'icon': '🚶'},
    {'id': 'moderate', 'label': 'Moderate', 'icon': '🏃'},
    {'id': 'intense', 'label': 'Intense', 'icon': '💪'},
  ];
}
