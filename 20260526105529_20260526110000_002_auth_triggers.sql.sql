/*
  # Auth Triggers for User Creation

  1. Purpose
    - Automatically create user record in `users` table when a user signs up in Supabase Auth
    - Automatically create subscription record in `subscriptions` table for new users
    - Ensures data consistency and avoids race conditions

  2. Functions Created
    - `handle_new_user()`: Trigger function that inserts into users and subscriptions tables
      - Creates user record with auth.uuid() and auth email
      - Creates subscription record with default free plan

  3. Triggers
    - `on_auth_user_created`: Fires after INSERT on auth.users
      - Calls handle_new_user() to create related records

  4. Security Notes
    - This trigger runs with SECURITY DEFINER privileges
    - The function belongs to postgres superuser to bypass RLS
    - Only triggered by auth schema insertions (controlled by Supabase Auth)
*/

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.users (id, email)
  VALUES (NEW.id, NEW.email);
  
  INSERT INTO public.subscriptions (user_id, plan, status)
  VALUES (NEW.id, 'free', 'inactive');
  
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();