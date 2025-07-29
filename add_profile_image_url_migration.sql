-- Add profile_image_url column to user_profiles table
ALTER TABLE user_profiles 
ADD COLUMN profile_image_url TEXT;

-- Add comment for documentation
COMMENT ON COLUMN user_profiles.profile_image_url IS 'URL of the user profile image stored in Supabase Storage';