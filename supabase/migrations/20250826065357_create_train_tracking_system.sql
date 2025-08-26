-- Location: supabase/migrations/20250826065357_create_train_tracking_system.sql
-- Schema Analysis: No existing schema (fresh project)
-- Integration Type: Complete new train tracking system
-- Dependencies: None (base schema creation)

-- 1. Custom Types
CREATE TYPE public.train_status AS ENUM ('on_time', 'delayed', 'cancelled', 'departed', 'arrived');
CREATE TYPE public.booking_status AS ENUM ('confirmed', 'waiting_list', 'rac', 'cancelled');
CREATE TYPE public.user_role AS ENUM ('passenger', 'admin', 'operator');
CREATE TYPE public.search_type AS ENUM ('train_search', 'pnr_status', 'live_tracking', 'station_schedule');

-- 2. Core User Management
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    phone TEXT,
    role public.user_role DEFAULT 'passenger'::public.user_role,
    preferences JSONB DEFAULT '{"notifications": true, "theme": "light", "language": "en"}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Railway Stations
CREATE TABLE public.stations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    code TEXT NOT NULL UNIQUE,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_major_station BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Train Information
CREATE TABLE public.trains (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    number TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    type TEXT NOT NULL, -- Express, Superfast, Local, etc.
    source_station_id UUID REFERENCES public.stations(id),
    destination_station_id UUID REFERENCES public.stations(id),
    total_distance INTEGER, -- in kilometers
    running_days TEXT NOT NULL DEFAULT '1234567', -- 1=Monday, 7=Sunday
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 5. Train Routes (Intermediate Stations)
CREATE TABLE public.train_routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    train_id UUID REFERENCES public.trains(id) ON DELETE CASCADE,
    station_id UUID REFERENCES public.stations(id),
    sequence_number INTEGER NOT NULL,
    arrival_time TIME,
    departure_time TIME,
    halt_duration INTEGER DEFAULT 0, -- in minutes
    distance_from_source INTEGER, -- cumulative distance
    platform_number TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(train_id, station_id),
    UNIQUE(train_id, sequence_number)
);

-- 6. Live Train Status
CREATE TABLE public.live_train_status (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    train_id UUID REFERENCES public.trains(id) ON DELETE CASCADE,
    current_station_id UUID REFERENCES public.stations(id),
    status public.train_status DEFAULT 'on_time'::public.train_status,
    delay_minutes INTEGER DEFAULT 0,
    expected_arrival TIMESTAMPTZ,
    expected_departure TIMESTAMPTZ,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    date_of_journey DATE NOT NULL,
    current_location_lat DECIMAL(10, 8),
    current_location_lng DECIMAL(11, 8),
    speed_kmph INTEGER DEFAULT 0,
    UNIQUE(train_id, date_of_journey)
);

-- 7. User Search History
CREATE TABLE public.search_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    search_type public.search_type NOT NULL,
    from_station_id UUID REFERENCES public.stations(id),
    to_station_id UUID REFERENCES public.stations(id),
    journey_date DATE,
    search_query JSONB, -- flexible for different search types
    is_favorite BOOLEAN DEFAULT false,
    searched_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 8. User Bookings/PNR Records
CREATE TABLE public.bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    pnr_number TEXT NOT NULL UNIQUE,
    train_id UUID REFERENCES public.trains(id),
    from_station_id UUID REFERENCES public.stations(id),
    to_station_id UUID REFERENCES public.stations(id),
    journey_date DATE NOT NULL,
    booking_status public.booking_status DEFAULT 'confirmed'::public.booking_status,
    passenger_details JSONB NOT NULL, -- array of passenger info
    seat_details JSONB, -- coach, seat numbers, etc.
    fare_details JSONB, -- booking fare, cancellation charges, etc.
    booking_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 9. User Notifications
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT DEFAULT 'general', -- train_delay, booking_update, general
    data JSONB, -- additional context data
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 10. Essential Indexes
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_stations_code ON public.stations(code);
CREATE INDEX idx_trains_number ON public.trains(number);
CREATE INDEX idx_train_routes_train_id ON public.train_routes(train_id);
CREATE INDEX idx_train_routes_station_id ON public.train_routes(station_id);
CREATE INDEX idx_live_train_status_train_id ON public.live_train_status(train_id);
CREATE INDEX idx_live_train_status_date ON public.live_train_status(date_of_journey);
CREATE INDEX idx_search_history_user_id ON public.search_history(user_id);
CREATE INDEX idx_search_history_favorite ON public.search_history(is_favorite) WHERE is_favorite = true;
CREATE INDEX idx_bookings_user_id ON public.bookings(user_id);
CREATE INDEX idx_bookings_pnr ON public.bookings(pnr_number);
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_unread ON public.notifications(user_id, is_read) WHERE is_read = false;

-- 11. Enable RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.search_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Public read access for reference data
ALTER TABLE public.stations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trains ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.train_routes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.live_train_status ENABLE ROW LEVEL SECURITY;

-- 12. Functions for automatic user profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'role', 'passenger')::public.user_role
  );
  RETURN NEW;
END;
$$;

-- 13. Trigger for new user creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 14. RLS Policies

-- Pattern 1: Core user table (user_profiles) - Simple only, no functions
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 2: Simple user ownership for private data
CREATE POLICY "users_manage_own_search_history"
ON public.search_history
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_bookings"
ON public.bookings
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_notifications"
ON public.notifications
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 4: Public read access for reference data
CREATE POLICY "public_can_read_stations"
ON public.stations
FOR SELECT
TO public
USING (true);

CREATE POLICY "public_can_read_trains"
ON public.trains
FOR SELECT
TO public
USING (true);

CREATE POLICY "public_can_read_train_routes"
ON public.train_routes
FOR SELECT
TO public
USING (true);

CREATE POLICY "public_can_read_live_train_status"
ON public.live_train_status
FOR SELECT
TO public
USING (true);

-- Admin-only write access for reference data using auth metadata
CREATE OR REPLACE FUNCTION public.is_admin_from_auth()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM auth.users au
    WHERE au.id = auth.uid() 
    AND (au.raw_user_meta_data->>'role' = 'admin' 
         OR au.raw_app_meta_data->>'role' = 'admin'
         OR au.raw_user_meta_data->>'role' = 'operator'
         OR au.raw_app_meta_data->>'role' = 'operator')
)
$$;

CREATE POLICY "admin_can_manage_stations"
ON public.stations
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

CREATE POLICY "admin_can_manage_trains"
ON public.trains
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

CREATE POLICY "admin_can_manage_train_routes"
ON public.train_routes
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

CREATE POLICY "admin_can_manage_live_train_status"
ON public.live_train_status
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- 15. Mock Data for Development and Testing
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    user_uuid UUID := gen_random_uuid();
    
    -- Station UUIDs
    delhi_id UUID := gen_random_uuid();
    mumbai_id UUID := gen_random_uuid();
    chennai_id UUID := gen_random_uuid();
    bangalore_id UUID := gen_random_uuid();
    kolkata_id UUID := gen_random_uuid();
    
    -- Train UUIDs
    rajdhani_id UUID := gen_random_uuid();
    shatabdi_id UUID := gen_random_uuid();
    duronto_id UUID := gen_random_uuid();
BEGIN
    -- Create auth users with required fields for authentication
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@traintracker.com', crypt('admin123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Admin User", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'user@traintracker.com', crypt('user123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Regular User", "role": "passenger"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Insert Major Indian Railway Stations
    INSERT INTO public.stations (id, name, code, city, state, latitude, longitude, is_major_station) VALUES
        (delhi_id, 'New Delhi', 'NDLS', 'New Delhi', 'Delhi', 28.6438, 77.2167, true),
        (mumbai_id, 'Mumbai Central', 'BCT', 'Mumbai', 'Maharashtra', 18.9697, 72.8205, true),
        (chennai_id, 'Chennai Central', 'MAS', 'Chennai', 'Tamil Nadu', 13.0827, 80.2707, true),
        (bangalore_id, 'Bangalore City', 'SBC', 'Bangalore', 'Karnataka', 12.9716, 77.5946, true),
        (kolkata_id, 'Howrah Junction', 'HWH', 'Kolkata', 'West Bengal', 22.5726, 88.3639, true);

    -- Insert Popular Trains
    INSERT INTO public.trains (id, number, name, type, source_station_id, destination_station_id, total_distance, running_days) VALUES
        (rajdhani_id, '12301', 'Rajdhani Express', 'Rajdhani', delhi_id, mumbai_id, 1384, '1234567'),
        (shatabdi_id, '12002', 'Shatabdi Express', 'Shatabdi', delhi_id, bangalore_id, 2180, '1234567'),
        (duronto_id, '12259', 'Duronto Express', 'Duronto', delhi_id, chennai_id, 2180, '134567');

    -- Insert Train Routes for Rajdhani Express (Delhi to Mumbai)
    INSERT INTO public.train_routes (train_id, station_id, sequence_number, arrival_time, departure_time, halt_duration, distance_from_source) VALUES
        (rajdhani_id, delhi_id, 1, NULL, '16:55', 0, 0),
        (rajdhani_id, mumbai_id, 2, '08:35', NULL, 0, 1384);

    -- Insert Live Train Status
    INSERT INTO public.live_train_status (train_id, current_station_id, status, delay_minutes, date_of_journey, speed_kmph) VALUES
        (rajdhani_id, delhi_id, 'on_time', 0, CURRENT_DATE, 120),
        (shatabdi_id, bangalore_id, 'delayed', 30, CURRENT_DATE, 0),
        (duronto_id, chennai_id, 'arrived', 15, CURRENT_DATE, 0);

    -- Insert Sample Search History
    INSERT INTO public.search_history (user_id, search_type, from_station_id, to_station_id, journey_date, is_favorite, search_query) VALUES
        (user_uuid, 'train_search', delhi_id, mumbai_id, CURRENT_DATE + INTERVAL '1 day', true, '{"departure_time": "morning"}'::jsonb),
        (user_uuid, 'train_search', chennai_id, bangalore_id, CURRENT_DATE + INTERVAL '2 days', false, '{"class": "3AC"}'::jsonb),
        (user_uuid, 'live_tracking', delhi_id, mumbai_id, CURRENT_DATE, false, '{"train_number": "12301"}'::jsonb);

    -- Insert Sample Booking
    INSERT INTO public.bookings (user_id, pnr_number, train_id, from_station_id, to_station_id, journey_date, booking_status, passenger_details, seat_details, fare_details) VALUES
        (user_uuid, 'PNR1234567890', rajdhani_id, delhi_id, mumbai_id, CURRENT_DATE + INTERVAL '3 days', 'confirmed',
         '[{"name": "John Doe", "age": 35, "gender": "M"}]'::jsonb,
         '{"coach": "A1", "seat": "12", "berth": "LB"}'::jsonb,
         '{"base_fare": 2500, "total_fare": 2750, "booking_fee": 250}'::jsonb);

    -- Insert Sample Notifications
    INSERT INTO public.notifications (user_id, title, message, type, data) VALUES
        (user_uuid, 'Train Delay Alert', 'Your train 12002 is running 30 minutes late', 'train_delay', '{"train_number": "12002", "delay": 30}'::jsonb),
        (user_uuid, 'Booking Confirmation', 'Your booking PNR1234567890 is confirmed', 'booking_update', '{"pnr": "PNR1234567890", "status": "confirmed"}'::jsonb);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;

-- 16. Helper Functions for Common Operations
CREATE OR REPLACE FUNCTION public.search_trains(
    p_from_station_code TEXT,
    p_to_station_code TEXT,
    p_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE(
    train_number TEXT,
    train_name TEXT,
    departure_time TIME,
    arrival_time TIME,
    duration INTERVAL,
    distance INTEGER
)
LANGUAGE sql
STABLE
AS $$
SELECT DISTINCT
    t.number as train_number,
    t.name as train_name,
    tr_from.departure_time,
    tr_to.arrival_time,
    (tr_to.arrival_time - tr_from.departure_time) as duration,
    (tr_to.distance_from_source - tr_from.distance_from_source) as distance
FROM public.trains t
JOIN public.train_routes tr_from ON t.id = tr_from.train_id
JOIN public.stations s_from ON tr_from.station_id = s_from.id
JOIN public.train_routes tr_to ON t.id = tr_to.train_id  
JOIN public.stations s_to ON tr_to.station_id = s_to.id
WHERE s_from.code = p_from_station_code
  AND s_to.code = p_to_station_code
  AND tr_from.sequence_number < tr_to.sequence_number
  AND t.is_active = true
ORDER BY tr_from.departure_time;
$$;

CREATE OR REPLACE FUNCTION public.get_live_train_status(p_train_number TEXT, p_date DATE DEFAULT CURRENT_DATE)
RETURNS TABLE(
    train_number TEXT,
    train_name TEXT,
    current_station TEXT,
    status public.train_status,
    delay_minutes INTEGER,
    last_updated TIMESTAMPTZ
)
LANGUAGE sql
STABLE
AS $$
SELECT 
    t.number as train_number,
    t.name as train_name,
    s.name as current_station,
    lts.status,
    lts.delay_minutes,
    lts.last_updated
FROM public.trains t
JOIN public.live_train_status lts ON t.id = lts.train_id
LEFT JOIN public.stations s ON lts.current_station_id = s.id
WHERE t.number = p_train_number
  AND lts.date_of_journey = p_date;
$$;