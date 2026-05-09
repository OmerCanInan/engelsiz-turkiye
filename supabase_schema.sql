-- 1. PostGIS Eklentisini Etkinleştir
CREATE EXTENSION IF NOT EXISTS postgis;

-- 2. Kullanıcı Profilleri Tablosu
-- auth.users ile ilişkili, ek engelli bilgileri tutar
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT,
    disability_type TEXT CHECK (disability_type IN ('ortopedik', 'gorme', 'isitme', 'zihinsel', 'diger')),
    disability_percentage INT,
    phone_number TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. İstihdam (İş İlanları)
CREATE TABLE IF NOT EXISTS public.jobs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    company_name TEXT NOT NULL,
    description TEXT,
    requirements TEXT[],
    disability_friendly_features TEXT[], -- Örn: "Asansör var", "Sesli yönlendirme"
    salary_range TEXT,
    location TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Eğitimler
CREATE TABLE IF NOT EXISTS public.courses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    instructor TEXT,
    category TEXT CHECK (category IN ('teknoloji', 'sanat', 'dil', 'mesleki', 'diger')),
    thumbnail_url TEXT,
    is_accessible_content BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Günlük Hayat - Sorun Bildirimi (PostGIS Kullanımı)
CREATE TABLE IF NOT EXISTS public.reports (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id),
    title TEXT NOT NULL,
    description TEXT,
    category TEXT CHECK (category IN ('yol_bozuklugu', 'rampa_eksikligi', 'asansor_arizasi', 'diger')),
    location GEOGRAPHY(POINT) NOT NULL, -- PostGIS konumu
    image_url TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'resolved')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Row Level Security (RLS) Ayarları
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

-- Herkes işleri ve eğitimleri görebilir
CREATE POLICY "Jobs are viewable by everyone" ON public.jobs FOR SELECT USING (true);
CREATE POLICY "Courses are viewable by everyone" ON public.courses FOR SELECT USING (true);

-- Kullanıcılar kendi profillerini ve raporlarını yönetebilir
CREATE POLICY "Users can view their own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update their own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert their own reports" ON public.reports FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can view their own reports" ON public.reports FOR SELECT USING (auth.uid() = user_id);
