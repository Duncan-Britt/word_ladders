-- DROP TABLE IF EXISTS solutions;
-- DROP TABLE IF EXISTS users;
-- DROP TABLE IF EXISTS puzzles;
-- DROP TABLE IF EXISTS generation_words;
-- DROP TABLE IF EXISTS validation_words;

CREATE TABLE IF NOT EXISTS users (
  id serial PRIMARY KEY,
  display_name text UNIQUE NOT NULL,
  password_digest text NOT NULL
);

CREATE TABLE IF NOT EXISTS puzzles (
  id SERIAL PRIMARY KEY,
  first TEXT NOT NULL,
  last TEXT NOT NULL,
  length INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS solutions (
  id SERIAL PRIMARY KEY,
  solution TEXT[50] NOT NULL,
  user_id INTEGER REFERENCES users (id) DEFAULT -1,
  puzzle_id INTEGER NOT NULL REFERENCES puzzles (id) ON DELETE CASCADE
);

CREATE INDEX ON solutions (user_id);
CREATE INDEX ON solutions (puzzle_id);

CREATE TABLE IF NOT EXISTS generation_words (
  word TEXT NOT NULL
);

CREATE INDEX ON generation_words (word);

CREATE TABLE IF NOT EXISTS validation_words (
  word TEXT NOT NULL
);

CREATE INDEX ON validation_words (word);
