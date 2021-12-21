CREATE TABLE IF NOT EXISTS users (
  id serial PRIMARY KEY,
  display_name text UNIQUE NOT NULL,
  password_digest text NOT NULL
)
