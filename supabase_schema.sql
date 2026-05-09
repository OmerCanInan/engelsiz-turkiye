-- 1. PostGIS Eklentisini Etkinleştir
CREATE EXTENSION IF NOT EXISTS postgis;

-- 2. Kullanıcı Profilleri Tablosu (Role eklendi)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT,
    role TEXT DEFAULT 'user' CHECK (role IN ('user', 'company', 'admin')),
    phone_number TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. İstihdam (İş İlanları)
CREATE TABLE IF NOT EXISTS public.jobs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    company_id UUID REFERENCES public.profiles(id),
    title TEXT NOT NULL,
    company_name TEXT NOT NULL,
    description TEXT,
    requirements TEXT[],
    disability_friendly_features TEXT[],
    salary_range TEXT,
    location TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Eğitimler
CREATE TABLE IF NOT EXISTS public.courses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    instructor TEXT, -- Nullable SQL'de kalsın, modelde fallback var
    category TEXT CHECK (category IN ('teknoloji', 'sanat', 'dil', 'mesleki', 'diger')),
    thumbnail_url TEXT,
    is_accessible_content BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Günlük Hayat - Sorun Bildirimi
CREATE TABLE IF NOT EXISTS public.reports (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id),
    title TEXT NOT NULL,
    description TEXT,
    category TEXT CHECK (category IN ('yol_bozuklugu', 'rampa_eksikligi', 'asansor_arizasi', 'diger')),
    location GEOGRAPHY(POINT) NOT NULL,
    image_url TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'resolved')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS Politikaları
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

-- Profiller: Herkes kendi profilini görebilir/güncelleyebilir
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- İşler: Herkes onaylı işleri görebilir. Sadece şirketler ve adminler ekleyebilir.
CREATE POLICY "Everyone can view approved jobs" ON public.jobs FOR SELECT USING (status = 'approved');
CREATE POLICY "Companies can insert jobs" ON public.jobs FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND (role = 'company' OR role = 'admin'))
);

-- Eğitimler: Herkes görebilir. Sadece adminler yönetebilir.
CREATE POLICY "Everyone can view courses" ON public.courses FOR SELECT USING (true);

-- Raporlar: Kullanıcılar kendi raporlarını görebilir ve ekleyebilir.
CREATE POLICY "Users can manage own reports" ON public.reports FOR ALL USING (auth.uid() = user_id);
