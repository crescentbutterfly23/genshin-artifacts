// Artifact Appraiser cloud settings.
// Fill these in from Supabase > Project Settings > API.
// Both values are meant to be public: the database rules in supabase/setup.sql keep each account private.
// NEVER put the "service_role" key here or anywhere in this repository.
window.APPRAISER_CLOUD = {
  url: "",      // e.g. "https://abcdefgh.supabase.co"
  anonKey: ""   // the "anon public" key
};
