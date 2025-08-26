import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Station {
  final String id;
  final String name;
  final String code;
  final String city;
  final String state;
  final double? latitude;
  final double? longitude;
  final bool isMajorStation;
  final DateTime createdAt;

  const Station({
    required this.id,
    required this.name,
    required this.code,
    required this.city,
    required this.state,
    this.latitude,
    this.longitude,
    required this.isMajorStation,
    required this.createdAt,
  });

  factory Station.fromJson(Map<String, dynamic> json) => Station(
    id: json['id'],
    name: json['name'],
    code: json['code'],
    city: json['city'],
    state: json['state'],
    latitude: json['latitude']?.toDouble(),
    longitude: json['longitude']?.toDouble(),
    isMajorStation: json['isMajorStation'],
    createdAt: DateTime.parse(json['createdAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'city': city,
    'state': state,
    'latitude': latitude,
    'longitude': longitude,
    'isMajorStation': isMajorStation,
    'createdAt': createdAt.toIso8601String(),
  };

  @override
  String toString() => '$name ($code)';
}

@JsonSerializable()
class Train {
  final String id;
  final String number;
  final String name;
  final String type;
  final String? sourceStationId;
  final String? destinationStationId;
  final int? totalDistance;
  final String runningDays;
  final bool isActive;
  final DateTime createdAt;

  const Train({
    required this.id,
    required this.number,
    required this.name,
    required this.type,
    this.sourceStationId,
    this.destinationStationId,
    this.totalDistance,
    required this.runningDays,
    required this.isActive,
    required this.createdAt,
  });

  factory Train.fromJson(Map<String, dynamic> json) => Train(
    id: json['id'],
    number: json['number'],
    name: json['name'],
    type: json['type'],
    sourceStationId: json['sourceStationId'],
    destinationStationId: json['destinationStationId'],
    totalDistance: json['totalDistance'],
    runningDays: json['runningDays'],
    isActive: json['isActive'],
    createdAt: DateTime.parse(json['createdAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'number': number,
    'name': name,
    'type': type,
    'sourceStationId': sourceStationId,
    'destinationStationId': destinationStationId,
    'totalDistance': totalDistance,
    'runningDays': runningDays,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
  };

  @override
  String toString() => '$number - $name';
}

@JsonSerializable()
class LiveTrainStatus {
  final String id;
  final String trainId;
  final String? currentStationId;
  final String status;
  final int delayMinutes;
  final DateTime? expectedArrival;
  final DateTime? expectedDeparture;
  final DateTime lastUpdated;
  final DateTime dateOfJourney;
  final double? currentLocationLat;
  final double? currentLocationLng;
  final int speedKmph;

  const LiveTrainStatus({
    required this.id,
    required this.trainId,
    this.currentStationId,
    required this.status,
    required this.delayMinutes,
    this.expectedArrival,
    this.expectedDeparture,
    required this.lastUpdated,
    required this.dateOfJourney,
    this.currentLocationLat,
    this.currentLocationLng,
    required this.speedKmph,
  });

  factory LiveTrainStatus.fromJson(Map<String, dynamic> json) => LiveTrainStatus(
    id: json['id'],
    trainId: json['trainId'],
    currentStationId: json['currentStationId'],
    status: json['status'],
    delayMinutes: json['delayMinutes'],
    expectedArrival: json['expectedArrival'] != null ? DateTime.parse(json['expectedArrival']) : null,
    expectedDeparture: json['expectedDeparture'] != null ? DateTime.parse(json['expectedDeparture']) : null,
    lastUpdated: DateTime.parse(json['lastUpdated']),
    dateOfJourney: DateTime.parse(json['dateOfJourney']),
    currentLocationLat: json['currentLocationLat']?.toDouble(),
    currentLocationLng: json['currentLocationLng']?.toDouble(),
    speedKmph: json['speedKmph'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'trainId': trainId,
    'currentStationId': currentStationId,
    'status': status,
    'delayMinutes': delayMinutes,
    'expectedArrival': expectedArrival?.toIso8601String(),
    'expectedDeparture': expectedDeparture?.toIso8601String(),
    'lastUpdated': lastUpdated.toIso8601String(),
    'dateOfJourney': dateOfJourney.toIso8601String(),
    'currentLocationLat': currentLocationLat,
    'currentLocationLng': currentLocationLng,
    'speedKmph': speedKmph,
  };

  bool get isDelayed => delayMinutes > 0;
  bool get isOnTime => status == 'on_time' && delayMinutes == 0;
}

@JsonSerializable()
class SearchHistory {
  final String id;
  final String userId;
  final String searchType;
  final String? fromStationId;
  final String? toStationId;
  final DateTime? journeyDate;
  final Map<String, dynamic>? searchQuery;
  final bool isFavorite;
  final DateTime searchedAt;

  const SearchHistory({
    required this.id,
    required this.userId,
    required this.searchType,
    this.fromStationId,
    this.toStationId,
    this.journeyDate,
    this.searchQuery,
    required this.isFavorite,
    required this.searchedAt,
  });

  factory SearchHistory.fromJson(Map<String, dynamic> json) => SearchHistory(
    id: json['id'],
    userId: json['userId'],
    searchType: json['searchType'],
    fromStationId: json['fromStationId'],
    toStationId: json['toStationId'],
    journeyDate: json['journeyDate'] != null ? DateTime.parse(json['journeyDate']) : null,
    searchQuery: json['searchQuery'],
    isFavorite: json['isFavorite'],
    searchedAt: DateTime.parse(json['searchedAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'searchType': searchType,
    'fromStationId': fromStationId,
    'toStationId': toStationId,
    'journeyDate': journeyDate?.toIso8601String(),
    'searchQuery': searchQuery,
    'isFavorite': isFavorite,
    'searchedAt': searchedAt.toIso8601String(),
  };
}

@JsonSerializable()
class TrainBooking {
  final String id;
  final String userId;
  final String pnrNumber;
  final String? trainId;
  final String? fromStationId;
  final String? toStationId;
  final DateTime journeyDate;
  final String bookingStatus;
  final List<Map<String, dynamic>> passengerDetails;
  final Map<String, dynamic>? seatDetails;
  final Map<String, dynamic>? fareDetails;
  final DateTime bookingDate;
  final DateTime createdAt;

  const TrainBooking({
    required this.id,
    required this.userId,
    required this.pnrNumber,
    this.trainId,
    this.fromStationId,
    this.toStationId,
    required this.journeyDate,
    required this.bookingStatus,
    required this.passengerDetails,
    this.seatDetails,
    this.fareDetails,
    required this.bookingDate,
    required this.createdAt,
  });

  factory TrainBooking.fromJson(Map<String, dynamic> json) => TrainBooking(
    id: json['id'],
    userId: json['userId'],
    pnrNumber: json['pnrNumber'],
    trainId: json['trainId'],
    fromStationId: json['fromStationId'],
    toStationId: json['toStationId'],
    journeyDate: DateTime.parse(json['journeyDate']),
    bookingStatus: json['bookingStatus'],
    passengerDetails: List<Map<String, dynamic>>.from(json['passengerDetails']),
    seatDetails: json['seatDetails'],
    fareDetails: json['fareDetails'],
    bookingDate: DateTime.parse(json['bookingDate']),
    createdAt: DateTime.parse(json['createdAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'pnrNumber': pnrNumber,
    'trainId': trainId,
    'fromStationId': fromStationId,
    'toStationId': toStationId,
    'journeyDate': journeyDate.toIso8601String(),
    'bookingStatus': bookingStatus,
    'passengerDetails': passengerDetails,
    'seatDetails': seatDetails,
    'fareDetails': fareDetails,
    'bookingDate': bookingDate.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };
}

@JsonSerializable()
class UserNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  const UserNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) => UserNotification(
    id: json['id'],
    userId: json['userId'],
    title: json['title'],
    message: json['message'],
    type: json['type'],
    data: json['data'],
    isRead: json['isRead'],
    createdAt: DateTime.parse(json['createdAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'message': message,
    'type': type,
    'data': data,
    'isRead': isRead,
    'createdAt': createdAt.toIso8601String(),
  };
}

@JsonSerializable()
class TrainSearchResult {
  final String trainNumber;
  final String trainName;
  final String? departureTime;
  final String? arrivalTime;
  final String? duration;
  final int? distance;

  const TrainSearchResult({
    required this.trainNumber,
    required this.trainName,
    this.departureTime,
    this.arrivalTime,
    this.duration,
    this.distance,
  });

  factory TrainSearchResult.fromJson(Map<String, dynamic> json) => TrainSearchResult(
    trainNumber: json['trainNumber'],
    trainName: json['trainName'],
    departureTime: json['departureTime'],
    arrivalTime: json['arrivalTime'],
    duration: json['duration'],
    distance: json['distance'],
  );

  Map<String, dynamic> toJson() => {
    'trainNumber': trainNumber,
    'trainName': trainName,
    'departureTime': departureTime,
    'arrivalTime': arrivalTime,
    'duration': duration,
    'distance': distance,
  };
}

@JsonSerializable()
class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String role;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
    required this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    email: json['email'],
    fullName: json['fullName'],
    phone: json['phone'],
    role: json['role'],
    preferences: json['preferences'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'phone': phone,
    'role': role,
    'preferences': preferences,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}