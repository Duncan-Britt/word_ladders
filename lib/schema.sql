-- DROP TABLE IF EXISTS solutions;
-- DROP TABLE IF EXISTS users;
-- DROP TABLE IF EXISTS puzzles;
DROP TABLE IF EXISTS generation_words;
DROP TABLE IF EXISTS validation_words;

CREATE TABLE IF NOT EXISTS users (
  id serial PRIMARY KEY,
  display_name text UNIQUE NOT NULL,
  password_digest text NOT NULL,
  n_solved integer DEFAULT 0 NOT NULL
);

INSERT INTO users VALUES (0, 'AI', '');

CREATE TABLE IF NOT EXISTS puzzles (
  id SERIAL PRIMARY KEY,
  first TEXT NOT NULL,
  last TEXT NOT NULL,
  length INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS solutions (
  id SERIAL PRIMARY KEY,
  solution TEXT[50] NOT NULL,
  user_id INTEGER DEFAULT 0 REFERENCES users (id) ON DELETE CASCADE,
  puzzle_id INTEGER NOT NULL REFERENCES puzzles (id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS ON solutions (user_id);
CREATE INDEX IF NOT EXISTS ON solutions (puzzle_id);

DELETE FROM solutions a USING solutions b
WHERE a.id < b.id AND a.user_id = b.user_id AND a.puzzle_id = b.puzzle_id;

ALTER TABLE solutions
ADD UNIQUE (user_id, puzzle_id);

ALTER TABLE solutions
ALTER COLUMN user_id SET DEFAULT 0;

ALTER TABLE solutions
ALTER COLUMN user_id SET NOT NULL;

-- CREATE TABLE IF NOT EXISTS generation_words (
--   word TEXT NOT NULL
-- );
--
-- CREATE INDEX ON generation_words (word);
--
-- CREATE TABLE IF NOT EXISTS validation_words (
--   word TEXT NOT NULL
-- );
--
-- CREATE INDEX ON validation_words (word);
