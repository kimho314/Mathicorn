-- Create avatars storage bucket if it doesn't exist
-- This migration ensures the storage bucket exists for profile image uploads

-- Note: Storage buckets are typically created through the Supabase dashboard
-- or using the Supabase CLI. This is a reference for manual creation.

-- To create the bucket manually in Supabase dashboard:
-- 1. Go to Storage section
-- 2. Click "Create a new bucket"
-- 3. Name: avatars
-- 4. Public bucket: true (to allow public access to profile images)
-- 5. File size limit: 5MB (or as needed)
-- 6. Allowed MIME types: image/*

-- Or using Supabase CLI:
-- supabase storage create avatars --public

-- RLS policies for the avatars bucket
-- Users can upload their own profile images
CREATE POLICY "Users can upload their own profile images" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'avatars' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can update their own profile images
CREATE POLICY "Users can update their own profile images" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'avatars' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can delete their own profile images
CREATE POLICY "Users can delete their own profile images" ON storage.objects
FOR DELETE USING (
  bucket_id = 'avatars' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Anyone can view profile images (public access)
CREATE POLICY "Anyone can view profile images" ON storage.objects
FOR SELECT USING (bucket_id = 'avatars'); 