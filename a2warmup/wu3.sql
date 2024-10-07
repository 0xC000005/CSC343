-- Warmup Query 3

SET SEARCH_PATH TO VetWarmup;

-- You must not change the next 2 lines, the type definition, or the table definition.
DROP TYPE IF EXISTS age_type CASCADE;
DROP TABLE IF EXISTS wu3 CASCADE;

CREATE TYPE VetWarmup.age_type AS ENUM (
    'young', 'adult', 'senior'
    );

CREATE TABLE wu3
(
    month        INT,
    age          age_type NOT NULL,
    num_patients int      NOT NULL
);

DROP VIEW IF EXISTS patient_with_age_category CASCADE;
DROP VIEW IF EXISTS all_possible_age_category CASCADE;
DROP VIEW IF EXISTS all_months CASCADE;
DROP VIEW IF EXISTS all_months_and_ages CASCADE;
DROP VIEW IF EXISTS patient_with_age_category_and_month CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW patient_with_age_category AS
SELECT *,
       CASE
           WHEN extract(year from age(current_date, birth_date)) < 3 THEN 'young'::VetWarmup.age_type
           WHEN extract(year from age(current_date, birth_date)) >= 8 THEN 'senior'::VetWarmup.age_type
           ELSE 'adult'::VetWarmup.age_type
           END AS age_category
FROM VetWarmup.patient;

CREATE VIEW all_possible_age_category AS
SELECT 'young'::VetWarmup.age_type AS age_category
UNION
SELECT 'senior'::VetWarmup.age_type AS age_category
UNION
SELECT 'adult'::VetWarmup.age_type AS age_category;

CREATE VIEW all_months AS
SELECT generate_series(1, 12) AS month;

CREATE VIEW all_months_and_ages AS
SELECT all_months.month, all_possible_age_category.age_category
FROM all_months,
     all_possible_age_category;


CREATE VIEW patient_with_age_category_and_month AS
WITH appointment_with_qualification_in_2024 AS (SELECT DISTINCT appointment.p_id,
                                                                extract(month from appointment.scheduled_date) AS month
                                                FROM vetwarmup.appointment
                                                         JOIN vetwarmup.scheduledprocedurestaff
                                                              ON appointment.a_id = scheduledprocedurestaff.a_id
                                                         JOIN vetwarmup.qualification
                                                              ON scheduledprocedurestaff.e_id = qualification.e_id
                                                WHERE vetwarmup.qualification.qualification =
                                                      'Doctor of Veterinary Medicine (DVM)'
                                                  AND extract(year from appointment.scheduled_date) = 2024)
SELECT appointment_with_qualification_in_2024.month,
       patient_with_age_category.age_category,
       COUNT(patient_with_age_category.p_id)
FROM appointment_with_qualification_in_2024
         JOIN patient_with_age_category
              ON appointment_with_qualification_in_2024.p_id = patient_with_age_category.p_id
GROUP BY appointment_with_qualification_in_2024.month, patient_with_age_category.age_category
ORDER BY appointment_with_qualification_in_2024.month, patient_with_age_category.age_category;

INSERT INTO wu3
SELECT all_months_and_ages.month,
       all_months_and_ages.age_category,
       COALESCE(patient_with_age_category_and_month.count, 0)
FROM all_months_and_ages
         LEFT JOIN patient_with_age_category_and_month
                   ON all_months_and_ages.month = patient_with_age_category_and_month.month
                      AND all_months_and_ages.age_category = patient_with_age_category_and_month.age_category
ORDER BY all_months_and_ages.month, all_months_and_ages.age_category;

-- Make sure if at the month there is no patient with the age category, the num_patients is 0
-- SELECT all_months_and_ages.month,
--        all_months_and_ages.age_category,
--        COALESCE(patient_with_age_category_and_month.count, 0)
-- FROM all_months_and_ages
--          LEFT JOIN patient_with_age_category_and_month
--                    ON all_months_and_ages.month = patient_with_age_category_and_month.month
--                       AND all_months_and_ages.age_category = patient_with_age_category_and_month.age_category
-- ORDER BY all_months_and_ages.month, all_months_and_ages.age_category;



