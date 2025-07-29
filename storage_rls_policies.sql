-- Supabase Storage RLS Policies for avatars bucket
-- Run these SQL commands in your Supabase SQL Editor

-- 1. Enable RLS on storage.objects table (if not already enabled)
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- 2. Policy for users to upload their own profile images
CREATE POLICY "Users can upload their own profile images" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- 3. Policy for users to update their own profile images
CREATE POLICY "Users can update their own profile images" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- 4. Policy for users to delete their own profile images
CREATE POLICY "Users can delete their own profile images" ON storage.objects
FOR DELETE USING (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- 5. Policy for anyone to view profile images (public access)
CREATE POLICY "Anyone can view profile images" ON storage.objects
FOR SELECT USING (bucket_id = 'avatars');

-- 6. Alternative: If you want to allow authenticated users to upload to any folder in avatars
-- CREATE POLICY "Authenticated users can upload to avatars" ON storage.objects
-- FOR INSERT WITH CHECK (
--   bucket_id = 'avatars' AND
--   auth.role() = 'authenticated'
-- );

-- 7. Alternative: If you want to allow all operations for authenticated users
-- CREATE POLICY "Authenticated users can manage avatars" ON storage.objects
-- FOR ALL USING (
--   bucket_id = 'avatars' AND
--   auth.role() = 'authenticated'
-- ); 