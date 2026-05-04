-- Supabase Schema for Coaching Directory Platform

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- USERS TABLE
-- Stores master admin and sub-admins.
CREATE TABLE public.app_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('MASTER', 'SUB_ADMIN'))
);

-- INSTITUTES TABLE
CREATE TABLE public.institutes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.app_users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    logo TEXT,
    address TEXT,
    location TEXT,
    phone TEXT,
    email TEXT,
    website TEXT,
    demo_video_url TEXT,
    CONSTRAINT unique_user_institute UNIQUE (user_id)
);

-- BATCHES TABLE
CREATE TABLE public.batches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    institute_id UUID NOT NULL REFERENCES public.institutes(id) ON DELETE CASCADE,
    teacher_name TEXT NOT NULL,
    teacher_image TEXT,
    subject TEXT NOT NULL,
    batch_name TEXT NOT NULL,
    batch_timing TEXT,
    batch_duration TEXT,
    start_date TEXT,
    fee_structure TEXT
);

-- ROW LEVEL SECURITY (RLS) POLICIES
ALTER TABLE public.institutes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.batches ENABLE ROW LEVEL SECURITY;

-- 1. Institutes RLS
-- Anyone can read institutes
CREATE POLICY "Public can view institutes" 
ON public.institutes FOR SELECT 
USING (true);

-- (If using standard Supabase Auth, you'd use auth.uid() here. 
-- Since we are defining custom users right now, the backend will handle bypassing RLS using the Service Role Key)

-- 2. Batches RLS
-- Anyone can read batches
CREATE POLICY "Public can view batches" 
ON public.batches FOR SELECT 
USING (true);

-- INSERT DEFAULT MASTER ADMIN (password: admin123 generated with bcrypt)
INSERT INTO public.app_users (username, password_hash, role) 
VALUES ('admin', '$2a$10$E9... (replace with actual bcrypt hash of admin123)', 'MASTER');
