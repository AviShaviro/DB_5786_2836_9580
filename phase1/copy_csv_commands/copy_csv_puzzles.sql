
COPY TAGS(tag_id, tag_name, description)
FROM '/var/lib/postgresql/csv_data/tags.csv'
DELIMITER ',' CSV HEADER;

COPY PUZZLES(fen_string, solution_moves, difficulty_elo, tag_id)
FROM '/var/lib/postgresql/csv_data/puzzles.csv'
DELIMITER ',' CSV HEADER;

COPY DAILY_PUZZLES(daily_puzzle_id,puzzle_id,puzzle_date,title,bonus_xp)
FROM '/var/lib/postgresql/csv_data/daily_puzzles.csv'
DELIMITER ',' CSV HEADER;

COPY PUZZLE_ATTEMPT(attempt_id, user_id, puzzle_id, is_successful, time_taken_sec, attempt_date)
FROM '/var/lib/postgresql/csv_data/puzzle_attempt.csv'
DELIMITER ',' CSV HEADER;