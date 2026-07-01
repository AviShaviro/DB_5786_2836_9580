
COPY CHAPTERS(chapter_id,title,content_text,chapter_order,course_id)
FROM '/var/lib/postgresql/csv_data/CHAPTERS.csv'
DELIMITER ',' CSV HEADER;
