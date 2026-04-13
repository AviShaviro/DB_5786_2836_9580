CREATE TABLE USERS
(
  user_id SERIAL NOT NULL,
  PRIMARY KEY (user_id)
);

CREATE TABLE COURSES
(
  course_id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  publish_date DATE NOT NULL,
  user_id INT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES USERS(user_id)
);

CREATE TABLE CHAPTERS
(
  chapter_id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  content_text TEXT,
  chapter_order INT NOT NULL,
  course_id INT NOT NULL,
  FOREIGN KEY (course_id) REFERENCES COURSES(course_id)
);

CREATE TABLE TAGS
(
  tag_id SERIAL PRIMARY KEY,
  tag_name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
);

CREATE TABLE PUZZLES
(
  puzzle_id SERIAL PRIMARY KEY,
  fen_string VARCHAR(255) NOT NULL,
  solution_moves VARCHAR(255) NOT NULL,
  difficulty_elo INT,
  tag_id INT,
  FOREIGN KEY (tag_id) REFERENCES TAGS(tag_id)
);

CREATE TABLE DAILY_PUZZLES
(
  daily_puzzle_id SERIAL PRIMARY KEY,
  puzzle_id INT NOT NULL,
  puzzle_date DATE NOT NULL UNIQUE,
  title VARCHAR(255) NOT NULL,
  bonus_xp INT DEFAULT 10,
  FOREIGN KEY (puzzle_id) REFERENCES PUZZLES(puzzle_id)
);

CREATE TABLE COURSE_PROGRESS
(
  course_progress_id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  course_id INT NOT NULL,
  is_completed BOOLEAN DEFAULT FALSE,
  start_date DATE NOT NULL,
  completion_date DATE,
  FOREIGN KEY (user_id) REFERENCES USERS(user_id),
  FOREIGN KEY (course_id) REFERENCES COURSES(course_id)
);

CREATE TABLE PUZZLE_ATTEMPT
(
  attempt_id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  puzzle_id INT NOT NULL,
  is_successful BOOLEAN NOT NULL,
  time_taken_sec INT NOT NULL,
  attempt_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (puzzle_id) REFERENCES PUZZLES(puzzle_id),
  FOREIGN KEY (user_id) REFERENCES USERS(user_id)
);