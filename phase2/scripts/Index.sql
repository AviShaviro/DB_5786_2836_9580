CREATE INDEX idx_puzzles_difficulty ON PUZZLES(difficulty_elo);

CREATE INDEX idx_puzzle_attempts_user ON PUZZLE_ATTEMPT(user_id);

CREATE INDEX idx_chapters_course ON CHAPTERS(course_id);