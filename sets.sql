-- Use a set operation to find all terms when Jepson and Suzuki were both teaching. Include every occurrence
-- of a term from the result of both operands.

-- First find terms either Jeppson was teaching;
SELECT *
FROM university.offering
WHERE instructor = 'Jepson';

SELECT *
FROM university.offering
WHERE instructor = 'Suzuki';

-- Union the two queries and select the term
SELECT *
FROM university.offering
WHERE term IN (
    SELECT term
    FROM university.offering
    WHERE instructor = 'Jepson'
    INTERSECT ALL
    SELECT term
    FROM university.offering
    WHERE instructor = 'Suzuki'
);




-- Find the sID of students who have earned a grade of 85 or more in some course, or who have passed a course
-- taught by Atwood. Ensure that no sID occurs twice in the result

-- First find the sID of students who have earned a grade of 85 or more in some course
SELECT DISTINCT sid
FROM university.took
WHERE grade >= 85;

-- Find the sID of students who have passed a course taught by Atwood
SELECT DISTINCT sid
FROM university.took, university.offering
WHERE took.oid = offering.oid
AND instructor = 'Atwood';

-- Union the two queries and select the sID
SELECT DISTINCT sid
FROM university.took
WHERE sid IN (
    SELECT DISTINCT sid
    FROM university.took
    WHERE grade >= 85
    UNION
    SELECT DISTINCT sid
    FROM university.took, university.offering
    WHERE took.oid = offering.oid
    AND instructor = 'Atwood'
);


-- Find all terms when csc369 was not offered.

-- First find all terms when csc343 was offered
SELECT DISTINCT term
FROM university.offering
WHERE dept = 'CSC'
AND cnum = 343;

SELECT *
FROM university.offering;

-- Find all terms
SELECT DISTINCT term
FROM university.offering;

-- Use the EXCEPT operator to find all terms when csc369 was not offered
(SELECT DISTINCT term
FROM university.offering
WHERE dept = 'CSC')
EXCEPT
(SELECT DISTINCT term
FROM university.offering);


-- Alternatively, we can use the NOT IN operator
SELECT DISTINCT term
FROM university.offering
WHERE term NOT IN (
    SELECT DISTINCT term
    FROM university.offering
    WHERE dept = 'CSC'
    AND cnum = 343
);



-- Make a table with two columns: oID and results. In the results column, report either “high” (if that offering
-- had an average grade of 80 or higher), or “low” (if that offering had an average under 60). Offerings with
-- an average in between will not be included.

-- First find the average grade for each offering
SELECT oid,
CASE
    WHEN AVG(grade) >= 80 THEN 'high'
    WHEN AVG(grade) < 60 THEN 'low'
END AS results
FROM university.took
GROUP BY oid
HAVING AVG(grade) >= 80 OR AVG(grade) < 60;


SELECT oid, 'high' AS results
FROM university.took
GROUP BY oid
HAVING AVG(grade) >= 80;

SELECT oid, 'low' AS results
FROM university.took
GROUP BY oid
HAVING AVG(grade) < 60;

-- Union the two queries
(SELECT oid, 'high' AS results
FROM university.took
GROUP BY oid
HAVING AVG(grade) >= 80)
UNION
(SELECT oid, 'low' AS results
FROM university.took
GROUP BY oid
HAVING AVG(grade) < 60);

