-- Subqueries worksheet Q10, in the style of what you will submit for A2

-- Let’s say that a course has level “junior” if its cNum is between 100 and 299 inclusive, and has level “senior”
-- if its cNum is between 300 and 499 inclusive. Report the average grade, across all departments and course
-- offerings, for all junior courses and for all senior courses. Report your answer in a table that looks like this:
-- level | levelavg
-- ---------|-----------
-- junior |
-- senior |
-- Each average should be an average of the individual student grades, not an average of the course averages.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO University;
DROP TABLE IF EXISTS q10 CASCADE;

CREATE TABLE q10 (
    level CHAR(20) NOT NULL,
    levelavg FLOAT NOT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
-- If you do not define any views, you can delete the lines about views.
DROP VIEW IF EXISTS Grades CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW Grades AS
    SELECT offering.cnum, took.grade
    FROM university.took, university.offering
    WHERE Took.oid = offering.oid;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q10
(SELECT 'junior' AS level, AVG(grade) AS levelavg
FROM Grades
WHERE cnum BETWEEN 100 AND 299)
UNION
(SELECT 'senior' AS level, AVG(grade) AS levelavg
FROM Grades
WHERE cnum BETWEEN 300 AND 499);

-- display the result
SELECT * FROM q10;
