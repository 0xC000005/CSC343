-- Assignment 2 Query 4

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO A2VetClinic;
DROP TABLE IF EXISTS q4 CASCADE;

CREATE TABLE q4
(
    mentee INT NOT NULL,
    mentor INT
);


-- The clinic wants to establish a mentorship program where new employees who have worked there for less than
-- 90 days, and whose start date is no later than the current date, (“mentees”) are paired with more experienced
-- employee who has worked there for at least 2 years (“mentor”). Mentees are paired with a mentor who has
-- worked with all of the species the mentee has since they started. A mentor can be paired with multiple mentees,
-- and vice versa, and it is possible there may not be mentors for every new employee. Report the IDs of the
-- mentee and mentor. Dates are based on their start date relative to the current date. Use the AGE function to
-- check for a 2 year interval. For simplicity, we use a time resolution of only years for mentors, i.e., an employee
-- who has worked for 1 year and 364 days won’t qualify for the mentor position.

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
-- If you do not define any views, you can delete the lines about views.
DROP VIEW IF EXISTS employee_with_types CASCADE;
DROP VIEW IF EXISTS mentee_all_species CASCADE;
DROP VIEW IF EXISTS mentor_all_species CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW employee_with_types AS
SELECT employee.e_id,
       CASE
           WHEN current_date - employee.start_date < 90 AND employee.start_date <= current_date
               AND EXISTS(SELECT scheduledprocedurestaff.a_id
                          FROM scheduledprocedurestaff
                          WHERE scheduledprocedurestaff.e_id = employee.e_id)
               THEN 'mentee'
           WHEN age(current_date, employee.start_date) >= '2 years' THEN 'mentor'
           END                            AS type,
       current_date - employee.start_date AS days_worked
FROM employee;


CREATE VIEW mentee_all_species AS
SELECT DISTINCT employee.e_id, patient.species, employee_with_types.type
FROM employee
         JOIN employee_with_types ON employee.e_id = employee_with_types.e_id
         JOIN scheduledprocedurestaff ON employee.e_id = scheduledprocedurestaff.e_id
         JOIN appointment ON scheduledprocedurestaff.a_id = appointment.a_id
         JOIN patient ON appointment.p_id = patient.p_id
WHERE employee_with_types.type = 'mentee';


CREATE VIEW mentor_all_species AS
SELECT DISTINCT employee.e_id, patient.species, employee_with_types.type
FROM employee
         JOIN employee_with_types ON employee.e_id = employee_with_types.e_id
         JOIN scheduledprocedurestaff ON employee.e_id = scheduledprocedurestaff.e_id
         JOIN appointment ON scheduledprocedurestaff.a_id = appointment.a_id
         JOIN patient ON appointment.p_id = patient.p_id
WHERE employee_with_types.type = 'mentor';


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q4
WITH mentee_mentor_pairs AS (SELECT DISTINCT mentee.e_id AS mentee, mentor.e_id AS mentor
                             FROM mentee_all_species mentee
                                      CROSS JOIN mentor_all_species mentor
                             WHERE NOT EXISTS (SELECT species
                                               FROM mentee_all_species m
                                               WHERE m.e_id = mentee.e_id
                                               EXCEPT
                                               SELECT species
                                               FROM mentor_all_species mt
                                               WHERE mt.e_id = mentor.e_id))
SELECT DISTINCT mentee_all_species.e_id AS mentee, mentee_mentor_pairs.mentor
FROM mentee_all_species
         LEFT JOIN mentee_mentor_pairs ON mentee_all_species.e_id = mentee_mentor_pairs.mentee
WHERE mentee_all_species.e_id IS NOT NULL;
