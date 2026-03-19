CREATE SCHEMA IF NOT EXISTS "public";

CREATE TABLE "public"."Chapters" (
    "chapter_id" serial NOT NULL,
    "course_id" int NOT NULL,
    "chapter_order" int NOT NULL,
    "title" varchar(255) NOT NULL,
    "content_text" text,
    PRIMARY KEY ("chapter_id")
);

CREATE TABLE "public"."Course_Progress" (
    "user_id" int NOT NULL,
    "chapter_id" int NOT NULL,
    "is_completed" boolean,
    "completion_date" date,
    PRIMARY KEY ("user_id", "chapter_id")
);

CREATE TABLE "public"."Courses" (
    "course_id" serial NOT NULL,
    "title" varchar(255) NOT NULL,
    "creator_user_id" int NOT NULL,
    "publish_date" date,
    PRIMARY KEY ("course_id")
);

CREATE TABLE "public"."Puzzle_Attempts" (
    "attempt_id" serial NOT NULL,
    "puzzle_id" int NOT NULL,
    "user_id" int NOT NULL,
    "is_successful" boolean,
    "time_taken_sec" int,
    "attempt_date" timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("attempt_id")
);

CREATE TABLE "public"."Puzzles" (
    "puzzle_id" serial NOT NULL,
    "fen_string" varchar(255) NOT NULL,
    "solution_moves" varchar(255) NOT NULL,
    "difficulty_elo" int,
    "primary_tag_id" int,
    PRIMARY KEY ("puzzle_id")
);

CREATE TABLE "public"."Tags" (
    "tag_id" serial NOT NULL,
    "tag_name" varchar(100) NOT NULL UNIQUE,
    "description" text,
    PRIMARY KEY ("tag_id")
);

-- Foreign key constraints
-- Schema: public
ALTER TABLE "public"."Puzzles" ADD CONSTRAINT "fk_Puzzles_primary_tag_id_Tags_tag_id" FOREIGN KEY("primary_tag_id") REFERENCES "public"."Tags"("tag_id");
ALTER TABLE "public"."Puzzle_Attempts" ADD CONSTRAINT "fk_Puzzle_Attempts_puzzle_id_Puzzles_puzzle_id" FOREIGN KEY("puzzle_id") REFERENCES "public"."Puzzles"("puzzle_id");
ALTER TABLE "public"."Chapters" ADD CONSTRAINT "fk_Chapters_course_id_Courses_course_id" FOREIGN KEY("course_id") REFERENCES "public"."Courses"("course_id");
ALTER TABLE "public"."Course_Progress" ADD CONSTRAINT "fk_Course_Progress_chapter_id_Chapters_chapter_id" FOREIGN KEY("chapter_id") REFERENCES "public"."Chapters"("chapter_id");