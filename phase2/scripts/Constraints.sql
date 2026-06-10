ALTER TABLE CHAPTER_PROGRESS 
ADD CONSTRAINT check_completion_consistency 
CHECK ((is_completed = TRUE AND completion_date IS NOT NULL) OR (is_completed = FALSE AND completion_date IS NULL));


ALTER TABLE CHAPTER_PROGRESS 
ADD CONSTRAINT check_dates_order CHECK (completion_date >= start_date);


ALTER TABLE CHAPTERS 
ADD CONSTRAINT unique_chapter_order_per_course UNIQUE (course_id, chapter_order);