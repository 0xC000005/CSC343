-- Warmup Query 1

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO VetWarmup;
DROP TABLE IF EXISTS wu1 CASCADE;

CREATE TABLE wu1 (
    pr_id INT NOT NULL,
    e_id INT NOT NULL
);

-- -- Do this for each of the views that define your intermediate steps.
-- -- (But give them better names!) The IF EXISTS avoids generating an error
-- -- the first time this file is imported.
-- -- If you do not define any views, you can delete the lines about views.
-- DROP VIEW IF EXISTS intermediate_step CASCADE;
--
-- -- Define views for your intermediate steps here:
-- CREATE VIEW intermediate_step AS ... ;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO wu1
SELECT pr_id, COUNT(DISTINCT e_id) AS num_staff
FROM vetwarmup.scheduledprocedurestaff
GROUP BY scheduledprocedurestaff.pr_id
HAVING COUNT(DISTINCT e_id) = (
    SELECT COUNT(DISTINCT e_id)
    FROM vetwarmup.scheduledprocedurestaff
    GROUP BY pr_id
    ORDER BY count(DISTINCT e_id) DESC
    LIMIT 1
    );
