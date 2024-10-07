-- set search_path TO unversity;

DROP VIEW IF EXISTS Counts;

-- First, create a view called Counts to hold, for each course, and each instructor who has taught it, their
-- number of offerings.

CREATE VIEW Counts AS
SELECT dept, cNum, instructor, COUNT(oid)
FROM offering
GROUP BY dept, cNum, instructor;

-- View the Counts view
SELECT * FROM Counts;

Select dept, cNum, instructor
FROM Counts
Where count >= ALL (
SELECT count
FROM Counts as c2
WHERE  Counts.dept = c2.dept AND Counts.cNum = c2.cNum
)
ORDER BY dept, cNum;

-- Use EXISTS to find the surname and email address of students who have never taken a CSC course.
SELECT surname, email
FROM student
WHERE NOT EXISTS (
    SELECT *
    FROM student s2, took, offering
    WHERE s2.sid = student.sid
    AND s2.sid = took.sid
    AND took.oid = offering.oid
    AND offering.dept = 'CSC');


-- Show all tables in the university schema
SELECT *
FROM took;


-- Let’s say that a course has level “junior” if its cNum is between 100 and 299 inclusive, and has level “senior”
-- if its cNum is between 300 and 499 inclusive. Report the average grade, across all departments and course
-- offerings, for all junior courses and for all senior courses

-- Idea: first we label the courses as junior or senior, then we group by the level and calculate the average grade
SELECT level, AVG(grade)
FROM (
    SELECT dept, cNum, grade,
    CASE
        WHEN cNum BETWEEN 100 AND 299 THEN 'junior'
        WHEN cNum BETWEEN 300 AND 499 THEN 'senior'
    END AS level
    FROM took, offering
    WHERE took.oid = offering.oid
) AS levels
GROUP BY level;


-- Find all tables under the schema
SELECT table_name
FROM information_schema.tables;

-- Select all columns from the university.took table
SELECT *
FROM university.took;

-- Got 7 rows
SELECT DISTINCT oid
FROM university.took
WHERE grade > 95
ORDER BY took.oid;

-- Got 10 rows
SELECT DISTINCT took.oid, took.grade
FROM university.took
WHERE took.grade > 95
ORDER BY took.oid;


-- Got 11 rows, the distinct remove the rows that has the same oid and the grade
SELECT took.oid, took.grade
FROM university.took
WHERE took.grade > 95
ORDER BY took.oid;

-- I want to first get all the regular rows with grade > 95, then get the distinct oid with the grade
-- Construct a subquery to get the oid with grade > 95
SELECT DISTINCT oid,
       (SELECT grade
        FROM university.took AS t2
        WHERE t2.oid = t1.oid AND t2.grade > 95
        LIMIT 1) AS grade
FROM university.took AS t1
WHERE grade > 95
ORDER BY oid;


-- Table A
SELECT 1 AS num
UNION
SELECT 1 AS num;

-- Result: 1 row
-- 1

-- Table B
SELECT 1 AS num
UNION ALL
SELECT 1 AS num;

-- Result: 2 rows
-- 1
-- 1
