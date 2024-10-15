-- Assignment 2 Query 1

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO A2VetClinic;
DROP TABLE IF EXISTS q1 CASCADE;

CREATE TABLE q1
(
    c_id         INT          NOT NULL,
    client_name  VARCHAR(30)  NOT NULL,
    email        VARCHAR(300) NOT NULL,
    patient_name VARCHAR(30)  NOT NULL
);
-- An “active” patient is one that has had any appointment in the last three calendar years, based on the current
-- year (e.g, in 2024, consider appointments in 2022, 2023, and 2024). Find all active patients that have had a
-- “diagnostic testing” procedure at least once per calendar year since their first appointment ever, but have not
-- had one yet or have one scheduled this calendar year. Report the client ID, client name, email, and patient
-- name.

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
-- If you do not define any views, you can delete the lines about views.
DROP VIEW IF EXISTS patient_and_year CASCADE;
DROP VIEW IF EXISTS last_three_years CASCADE;
DROP VIEW IF EXISTS active_patients CASCADE;
DROP VIEW IF EXISTS first_appointment CASCADE;
DROP VIEW IF EXISTS patient_with_year_since_first_appointment_until_last_year CASCADE;
DROP VIEW IF EXISTS patient_has_diagnostic_testing_year CASCADE;
DROP VIEW IF EXISTS patient_has_diagnostic_testing_first_until_last CASCADE;
DROP VIEW IF EXISTS patient_not_done_or_schedule_diagnostic_this_year CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW last_three_years AS
SELECT year
FROM (VALUES (EXTRACT(YEAR FROM CURRENT_DATE)),
             (EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL '1 year')),
             (EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL '2 year'))) AS years(year)
ORDER BY year DESC;


CREATE VIEW patient_and_year AS
SELECT DISTINCT appointment.p_id, extract(year from A2VetClinic.Appointment.scheduled_date) as year
FROM A2VetClinic.Appointment
         JOIN A2VetClinic.patient ON A2VetClinic.Appointment.p_id = A2VetClinic.patient.p_id;


CREATE VIEW active_patients AS
WITH last_three_years_patient_checklist AS
         (SELECT patients_last_three_years.p_id, last_three_years.year
          FROM (SELECT DISTINCT p_id FROM patient_and_year) AS patients_last_three_years
                   CROSS JOIN last_three_years)
SELECT DISTINCT p_id
FROM (SELECT *
      FROM last_three_years_patient_checklist
      INTERSECT
      SELECT *
      FROM patient_and_year) AS intersection_result
ORDER BY p_id;


CREATE VIEW first_appointment AS
SELECT DISTINCT p_id, min(year) as min_year
FROM patient_and_year
GROUP BY p_id
ORDER BY p_id;


CREATE VIEW patient_with_year_since_first_appointment_until_last_year AS
SELECT p_id,
       generate_series(min_year, EXTRACT(YEAR FROM CURRENT_DATE) - 1) AS year
FROM first_appointment
ORDER BY p_id, year;


CREATE VIEW patient_has_diagnostic_testing_year AS
WITH all_diagnostic_testing AS
         (SELECT DISTINCT a_id
          FROM scheduledprocedure
                   JOIN procedure on scheduledprocedure.pr_id = procedure.pr_id
          WHERE name = 'diagnostic testing')
SELECT DISTINCT p_id, extract(YEAR FROM scheduled_date) as year
FROM all_diagnostic_testing
         JOIN appointment ON all_diagnostic_testing.a_id = appointment.a_id
ORDER BY p_id, year;


CREATE VIEW patient_has_diagnostic_testing_first_until_last AS
SELECT DISTINCT p_id
FROM ((SELECT * FROM patient_with_year_since_first_appointment_until_last_year)
      INTERSECT
      (SELECT * FROM patient_has_diagnostic_testing_year)) as patient_has_diagnostic_testing_first_until_last_year
ORDER BY p_id;


CREATE VIEW patient_not_done_or_schedule_diagnostic_this_year AS
WITH patient_done_or_schedule_diagnostic_this_year AS
         (SELECT DISTINCT p_id
          FROM scheduledprocedure
                   JOIN procedure on scheduledprocedure.pr_id = procedure.pr_id
                   JOIN appointment on scheduledprocedure.a_id = appointment.a_id
          WHERE name = 'diagnostic testing'
            AND extract(year from scheduled_date) = extract(year from current_date))
SELECT p_id
FROM patient_has_diagnostic_testing_first_until_last
WHERE p_id NOT IN (SELECT p_id FROM patient_done_or_schedule_diagnostic_this_year);


-- -- Your query that answers the question goes below the "insert into" line:
INSERT INTO q1
WITH active_but_not_done_or_schedule_diagnostic_this_year AS
         (SELECT DISTINCT patient_not_done_or_schedule_diagnostic_this_year.p_id
          FROM patient_not_done_or_schedule_diagnostic_this_year
                   JOIN active_patients
                        ON patient_not_done_or_schedule_diagnostic_this_year.p_id = active_patients.p_id)
SELECT client.c_id, client.name AS client_name, client.email, patient.name AS patient_name
FROM active_but_not_done_or_schedule_diagnostic_this_year
         JOIN patient ON active_but_not_done_or_schedule_diagnostic_this_year.p_id = patient.p_id
         JOIN client ON patient.c_id = client.c_id;
