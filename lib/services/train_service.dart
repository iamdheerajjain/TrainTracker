import '../models/train_models.dart';
import './supabase_service.dart';

class TrainService {
  static final client = SupabaseService.instance.client;

  // Station Operations
  static Future<List<Station>> getAllStations({bool majorOnly = false}) async {
    try {
      var query = client.from('stations').select();

      if (majorOnly) {
        query = query.eq('is_major_station', true);
      }

      final response = await query.order('name', ascending: true);
      return response.map<Station>((json) => Station.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch stations: $error');
    }
  }

  static Future<List<Station>> searchStations(String query) async {
    try {
      final response = await client
          .from('stations')
          .select()
          .or('name.ilike.%$query%,code.ilike.%$query%,city.ilike.%$query%')
          .order('is_major_station', ascending: false)
          .order('name', ascending: true)
          .limit(20);

      return response.map<Station>((json) => Station.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to search stations: $error');
    }
  }

  static Future<Station?> getStationByCode(String code) async {
    try {
      final response =
          await client.from('stations').select().eq('code', code).maybeSingle();

      return response != null ? Station.fromJson(response) : null;
    } catch (error) {
      throw Exception('Failed to fetch station: $error');
    }
  }

  // Train Search Operations
  static Future<List<TrainSearchResult>> searchTrains({
    required String fromStationCode,
    required String toStationCode,
    DateTime? journeyDate,
  }) async {
    try {
      final response = await client.rpc('search_trains', params: {
        'p_from_station_code': fromStationCode,
        'p_to_station_code': toStationCode,
        'p_date': journeyDate?.toIso8601String().split('T')[0] ??
            DateTime.now().toIso8601String().split('T')[0],
      });

      return response
          .map<TrainSearchResult>((json) => TrainSearchResult.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to search trains: $error');
    }
  }

  static Future<List<Train>> getAllTrains() async {
    try {
      final response = await client
          .from('trains')
          .select()
          .eq('is_active', true)
          .order('name', ascending: true);

      return response.map<Train>((json) => Train.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch trains: $error');
    }
  }

  static Future<Train?> getTrainByNumber(String trainNumber) async {
    try {
      final response = await client
          .from('trains')
          .select()
          .eq('number', trainNumber)
          .maybeSingle();

      return response != null ? Train.fromJson(response) : null;
    } catch (error) {
      throw Exception('Failed to fetch train: $error');
    }
  }

  // Live Train Status
  static Future<LiveTrainStatus?> getLiveTrainStatus(String trainNumber,
      {DateTime? date}) async {
    try {
      final queryDate = date ?? DateTime.now();
      final response = await client.rpc('get_live_train_status', params: {
        'p_train_number': trainNumber,
        'p_date': queryDate.toIso8601String().split('T')[0],
      });

      if (response.isEmpty) return null;

      return LiveTrainStatus.fromJson(response.first);
    } catch (error) {
      throw Exception('Failed to fetch live train status: $error');
    }
  }

  static Future<List<LiveTrainStatus>> getAllLiveTrainStatus(
      {DateTime? date}) async {
    try {
      final queryDate = date ?? DateTime.now();
      var query = client.from('live_train_status').select('''
        id, train_id, current_station_id, status, delay_minutes,
        expected_arrival, expected_departure, last_updated,
        date_of_journey, current_location_lat, current_location_lng,
        speed_kmph
      ''');

      query = query.eq(
          'date_of_journey', queryDate.toIso8601String().split('T')[0]);

      final response = await query.order('last_updated', ascending: false);
      return response
          .map<LiveTrainStatus>((json) => LiveTrainStatus.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch live train status: $error');
    }
  }

  // Search History Operations
  static Future<List<SearchHistory>> getUserSearchHistory(String userId) async {
    try {
      final response = await client
          .from('search_history')
          .select()
          .eq('user_id', userId)
          .order('searched_at', ascending: false)
          .limit(20);

      return response
          .map<SearchHistory>((json) => SearchHistory.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch search history: $error');
    }
  }

  static Future<List<SearchHistory>> getFavoriteSearches(String userId) async {
    try {
      final response = await client
          .from('search_history')
          .select()
          .eq('user_id', userId)
          .eq('is_favorite', true)
          .order('searched_at', ascending: false);

      return response
          .map<SearchHistory>((json) => SearchHistory.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch favorite searches: $error');
    }
  }

  static Future<SearchHistory> addSearchHistory({
    required String userId,
    required String searchType,
    String? fromStationId,
    String? toStationId,
    DateTime? journeyDate,
    Map<String, dynamic>? searchQuery,
    bool isFavorite = false,
  }) async {
    try {
      final response = await client
          .from('search_history')
          .insert({
            'user_id': userId,
            'search_type': searchType,
            'from_station_id': fromStationId,
            'to_station_id': toStationId,
            'journey_date': journeyDate?.toIso8601String().split('T')[0],
            'search_query': searchQuery,
            'is_favorite': isFavorite,
          })
          .select()
          .single();

      return SearchHistory.fromJson(response);
    } catch (error) {
      throw Exception('Failed to add search history: $error');
    }
  }

  static Future<void> toggleFavoriteSearch(
      String searchId, bool isFavorite) async {
    try {
      await client
          .from('search_history')
          .update({'is_favorite': isFavorite}).eq('id', searchId);
    } catch (error) {
      throw Exception('Failed to update favorite status: $error');
    }
  }

  static Future<void> deleteSearchHistory(String searchId) async {
    try {
      await client.from('search_history').delete().eq('id', searchId);
    } catch (error) {
      throw Exception('Failed to delete search history: $error');
    }
  }

  // Booking/PNR Operations
  static Future<List<TrainBooking>> getUserBookings(String userId) async {
    try {
      final response = await client
          .from('bookings')
          .select()
          .eq('user_id', userId)
          .order('booking_date', ascending: false);

      return response
          .map<TrainBooking>((json) => TrainBooking.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch bookings: $error');
    }
  }

  static Future<TrainBooking?> getBookingByPNR(String pnr) async {
    try {
      final response = await client
          .from('bookings')
          .select()
          .eq('pnr_number', pnr)
          .maybeSingle();

      return response != null ? TrainBooking.fromJson(response) : null;
    } catch (error) {
      throw Exception('Failed to fetch booking: $error');
    }
  }

  // Notification Operations
  static Future<List<UserNotification>> getUserNotifications(
      String userId) async {
    try {
      final response = await client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return response
          .map<UserNotification>((json) => UserNotification.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch notifications: $error');
    }
  }

  static Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final response = await client
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false)
          .count();

      return response.count ?? 0;
    } catch (error) {
      throw Exception('Failed to fetch notification count: $error');
    }
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await client
          .from('notifications')
          .update({'is_read': true}).eq('id', notificationId);
    } catch (error) {
      throw Exception('Failed to mark notification as read: $error');
    }
  }

  static Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      await client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (error) {
      throw Exception('Failed to mark all notifications as read: $error');
    }
  }
}
