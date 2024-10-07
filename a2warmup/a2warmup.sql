-- display all schemas
SELECT schema_name FROM information_schema.schemata;

-- display all tables under the vetwarmup schema
SELECT table_name FROM information_schema.tables WHERE table_schema = 'vetwarmup';
-- client
-- patient
-- employee
-- qualification
-- supply
-- retailsupply
-- procedure
-- procedurequalification
-- proceduresupply
-- appointment
-- scheduledprocedure
-- scheduledprocedurestaff

-- Find the procedure(s) that have been done by the most staff. Report the procedure ID(s), and the number of
-- unique staff who have done that procedure
SELECT *
FROM vetwarmup.scheduledprocedurestaff;

-- Idea, group by the procedure id and count the number of staff
SELECT pr_id, COUNT(DISTINCT e_id)
FROM vetwarmup.scheduledprocedurestaff
GROUP BY pr_id
ORDER BY count(DISTINCT e_id) DESC;

SELECT *
FROM VetWarmup.scheduledprocedurestaff;


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

SELECT pr_id, count(DISTINCT e_id) AS num_staff
FROM vetwarmup.scheduledprocedurestaff
WHERE scheduledprocedurestaff.pr_id = (
    SELECT pr_id
    FROM vetwarmup.scheduledprocedurestaff
    GROUP BY pr_id
    ORDER BY count(e_id) DESC
    LIMIT 1
    )
GROUP BY pr_id;


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


-- A “high-needs” patient is one that has had more than one and a half times the average number of appointments
-- in the last calendar year (i.e., 2023). (Yes, the patient is included in the average.) Find the IDs of all high-needs
-- patients and the number of appointments they have scheduled in 2024.

-- Idea: first find the average number of appointments in 2023, then select those where the number of appointments is
-- more than 1.5 times the average

SELECT *
FROM vetwarmup.appointment
WHERE vetwarmup.appointment.scheduled_date >= '2023-01-01'
AND vetwarmup.appointment.scheduled_date < '2024-01-01';

SELECT COUNT(*) AS num_appointments, vetwarmup.appointment.p_id,
FROM vetwarmup.appointment
WHERE vetwarmup.appointment.scheduled_date >= '2023-01-01'
AND vetwarmup.appointment.scheduled_date < '2024-01-01'
GROUP BY vetwarmup.appointment.p_id;


-- Calculate the average number of appointments in 2023
SELECT AVG(num_appointments), COUNT(num_appointments)
FROM (
    SELECT COUNT(*) AS num_appointments
    FROM vetwarmup.appointment
    WHERE vetwarmup.appointment.scheduled_date >= '2023-01-01'
    AND vetwarmup.appointment.scheduled_date < '2024-01-01'
    GROUP BY vetwarmup.appointment.p_id
    ) AS num_appointments;

SELECT COUNT(*) AS num_appointments, p_id
FROM vetwarmup.appointment
WHERE vetwarmup.appointment.scheduled_date >= '2023-01-01'
AND vetwarmup.appointment.scheduled_date < '2024-01-01'
GROUP BY vetwarmup.appointment.p_id;


-- Find all rows of the appointment table where the number of appointments is more than 1.5 times the average and the
-- year is 2023
SELECT COUNT(*) AS num_appointments, vetwarmup.appointment.p_id
FROM vetwarmup.appointment
WHERE vetwarmup.appointment.scheduled_date >= '2023-01-01'
AND vetwarmup.appointment.scheduled_date < '2024-01-01'
GROUP BY vetwarmup.appointment.p_id
HAVING COUNT(*) > 1.5 * (
    SELECT AVG(num_appointments)
    FROM (
        SELECT COUNT(*) AS num_appointments
        FROM vetwarmup.appointment
        WHERE vetwarmup.appointment.scheduled_date >= '2023-01-01'
        AND vetwarmup.appointment.scheduled_date < '2024-01-01'
        GROUP BY vetwarmup.appointment.p_id
        ) AS num_appointments
    );



SELECT COUNT(*) AS num_appointments, vetwarmup.appointment.p_id
FROM vetwarmup.appointment
WHERE vetwarmup.appointment.scheduled_date >= '2024-01-01'
AND vetwarmup.appointment.scheduled_date < '2025-01-01'
GROUP BY vetwarmup.appointment.p_id
HAVING COUNT(*) > 1.5 * (
    SELECT AVG(num_appointments)
    FROM (
        SELECT COUNT(*) AS num_appointments
        FROM vetwarmup.appointment
        WHERE vetwarmup.appointment.scheduled_date >= '2023-01-01'
        AND vetwarmup.appointment.scheduled_date < '2024-01-01'
        GROUP BY vetwarmup.appointment.p_id
        ) AS num_appointments
    );

SELECT AVG(patient_2023.num_appointments) AS avg_num_appointments_2023
FROM (
    SELECT COUNT(*) AS num_appointments
    FROM vetwarmup.appointment
    WHERE vetwarmup.appointment.scheduled_date >= '2023-01-01'
    AND vetwarmup.appointment.scheduled_date < '2024-01-01'
    GROUP BY vetwarmup.appointment.p_id
    ) as patient_2023;


SELECT appointment.p_id, COUNT(*) AS num_appointments
FROM vetwarmup.appointment
WHERE vetwarmup.appointment.scheduled_date >= '2023-01-01'
  AND vetwarmup.appointment.scheduled_date < '2024-01-01'
GROUP BY vetwarmup.appointment.p_id
HAVING COUNT(*) > 1.5 * (
    SELECT AVG(num_appointments)
    FROM (
        SELECT COUNT(*) AS num_appointments
        FROM vetwarmup.appointment
        WHERE vetwarmup.appointment.scheduled_date >= '2023-01-01'
        AND vetwarmup.appointment.scheduled_date < '2024-01-01'
        GROUP BY vetwarmup.appointment.p_id
        ) AS num_appointments
    );

SELECT p_id
FROM vetwarmup.appointment
WHERE vetwarmup.appointment.scheduled_date >= '2023-01-01'
AND vetwarmup.appointment.scheduled_date < '2024-01-01'
GROUP BY vetwarmup.appointment.p_id
HAVING COUNT(*) > 1.5 * (
    SELECT AVG(num_appointments)
    FROM (
        SELECT COUNT(*) AS num_appointments
        FROM vetwarmup.appointment
        WHERE vetwarmup.appointment.scheduled_date >= '2023-01-01'
        AND vetwarmup.appointment.scheduled_date < '2024-01-01'
        GROUP BY vetwarmup.appointment.p_id
        ) AS num_appointments
    );


SELECT high_needs_patients.p_id, COUNT(*) AS num_appointments
FROM vetwarmup.appointment RIGHT JOIN (
    SELECT p_id
    FROM vetwarmup.appointment
    WHERE vetwarmup.appointment.scheduled_date >= '2023-01-01'
    AND vetwarmup.appointment.scheduled_date < '2024-01-01'
    GROUP BY vetwarmup.appointment.p_id
    HAVING COUNT(*) > 1.5 * (
        SELECT AVG(num_appointments)
        FROM (
            SELECT COUNT(*) AS num_appointments
            FROM vetwarmup.appointment
            WHERE vetwarmup.appointment.scheduled_date >= '2023-01-01'
            AND vetwarmup.appointment.scheduled_date < '2024-01-01'
            GROUP BY vetwarmup.appointment.p_id
            ) AS num_appointments
        )
    ) AS high_needs_patients ON vetwarmup.appointment.p_id = high_needs_patients.p_id
                                    AND appointment.scheduled_date >= '2024-01-01'
                                    AND appointment.scheduled_date < '2025-01-01'
GROUP BY high_needs_patients.p_id
ORDER BY high_needs_patients.p_id;






-- A patient is considered “young” if they are under 3 years old, “senior” if they are over 8 years old, and “adult”
-- otherwise. Their age should be calculated as of the current date.
-- For each month of 2024, report the number of patients in each age category who had an appointment where
-- they saw a vet (DVM). Include only those patients who saw in vet in 2024 in the results.
-- As part of this query, you will need to take a look at the PostgreSQL documentation to learn about the
-- command CAST. We have provided a type for you to use to represent the age category of a patient. You will
-- also have to look at the documentation to learn how to work with dates in PostgreSQL. In particular, we expect
-- EXTRACT will be helpful to you

-- Idea: first get a table with the age category of each patient, with their age calculated as of the current date

SELECT birth_date, extract(year from age(current_date, birth_date)) AS age
FROM vetwarmup.patient;

SELECT birth_date, extract(year from age(current_date, birth_date)) AS age,
       CASE
           WHEN extract(year from age(current_date, birth_date)) < 3 THEN 'young'
           WHEN extract(year from age(current_date, birth_date)) > 8 THEN 'senior'
           ELSE 'adult'
       END AS age_category
FROM vetwarmup.patient;

-- Now get the number of patient who had appointment at each month of 2024
SELECT extract(month from vetwarmup.appointment.scheduled_date) AS month,
       COUNT(vetwarmup.appointment.p_id) AS num_patients
FROM vetwarmup.appointment
GROUP BY extract(month from vetwarmup.appointment.scheduled_date);

SELECT *
FROM vetwarmup.appointment;

SELECT *
FROM vetwarmup.patient JOIN vetwarmup.appointment ON patient.p_id = appointment.p_id;


SELECT extract(month from vetwarmup.appointment.scheduled_date) AS month,
       COUNT(vetwarmup.appointment.p_id) AS num_patients,
       COUNT(CASE WHEN patient_with_age_category.age_category = 'young' THEN 1 ELSE NULL END) AS num_young,
       COUNT(CASE WHEN patient_with_age_category.age_category = 'senior' THEN 1 ELSE NULL END) AS num_senior,
       COUNT(CASE WHEN patient_with_age_category.age_category = 'adult' THEN 1 ELSE NULL END) AS num_adult

FROM (SELECT *, extract(year from age(current_date, birth_date)) AS age,
       CASE
           WHEN extract(year from age(current_date, birth_date)) < 3 THEN 'young'
           WHEN extract(year from age(current_date, birth_date)) > 8 THEN 'senior'
           ELSE 'adult'
       END AS age_category
      FROM vetwarmup.patient) AS patient_with_age_category
    JOIN
    vetwarmup.appointment ON patient_with_age_category.p_id = appointment.p_id

GROUP BY extract(month from vetwarmup.appointment.scheduled_date);


SELECT *,
       extract(year from age('2024-12-31', birth_date)) AS age,
       CASE
           WHEN extract(year from age('2024-12-31', birth_date)) < 3 THEN 'young'
           WHEN extract(year from age('2024-12-31', birth_date)) > 8 THEN 'senior'
           ELSE 'adult'
       END AS age_category
FROM vetwarmup.patient;




WITH patient_with_age_category AS (
    SELECT *,
           extract(year from age('2024-12-31', birth_date)) AS age,
           CASE
               WHEN extract(year from age(current_date, birth_date)) < 3 THEN 'young'
               WHEN extract(year from age(current_date, birth_date)) > 8 THEN 'senior'
               ELSE 'adult'
           END AS age_category
    FROM vetwarmup.patient
)

SELECT
    extract(month from appointment.scheduled_date) AS month,
    COUNT(appointment.p_id) AS num_patients,
    COUNT(CASE WHEN patient_with_age_category.age_category = 'young' THEN 1 ELSE NULL END) AS num_young,
    COUNT(CASE WHEN patient_with_age_category.age_category = 'senior' THEN 1 ELSE NULL END) AS num_senior,
    COUNT(CASE WHEN patient_with_age_category.age_category = 'adult' THEN 1 ELSE NULL END) AS num_adult
FROM
    patient_with_age_category
    JOIN vetwarmup.appointment ON patient_with_age_category.p_id = appointment.p_id
    JOIN vetwarmup.employee ON appointment.scheduled_by = employee.e_id
    JOIN vetwarmup.qualification ON employee.e_id = qualification.e_id
WHERE
    extract(year from appointment.scheduled_date) = 2024
    AND qualification.qualification = 'Doctor of Veterinary Medicine (DVM)'
GROUP BY
    extract(month from appointment.scheduled_date)
ORDER BY
    month;


SELECT *
FROM vetwarmup.scheduledprocedurestaff;

SELECT *
FROM vetwarmup.scheduledprocedurestaff JOIN vetwarmup.qualification ON scheduledprocedurestaff.e_id = qualification.e_id;

SELECT *
FROM vetwarmup.appointment;

CREATE TYPE VetWarmup.age_type AS ENUM (
	'young', 'adult', 'senior'
);

SELECT *,
       CASE
           WHEN extract(year from age('2024-12-31', birth_date)) < 3 THEN 'young'::VetWarmup.age_type
           WHEN extract(year from age('2024-12-31', birth_date)) > 8 THEN 'senior'::VetWarmup.age_type
           ELSE 'adult'::VetWarmup.age_type
       END AS age_category
FROM VetWarmup.patient;



SELECT *
FROM vetwarmup.patient JOIN vetwarmup.appointment ON patient.p_id = appointment.p_id
WHERE appointment.scheduled_date >= '2024-01-01'
AND appointment.scheduled_date < '2025-01-01';




WITH patient_with_age_category AS (
    SELECT *,
           CASE
               WHEN extract(year from age('2024-12-31', birth_date)) < 3 THEN 'young'::VetWarmup.age_type
               WHEN extract(year from age('2024-12-31', birth_date)) > 8 THEN 'senior'::VetWarmup.age_type
               ELSE 'adult'::VetWarmup.age_type
           END AS age_category
    FROM VetWarmup.patient
)
SELECT
    extract(month from vetwarmup.appointment.scheduled_date)::INT AS month,
    patient_with_age_category.age_category AS age,
    COUNT(vetwarmup.appointment.p_id) AS num_patients
FROM
    patient_with_age_category
    JOIN vetwarmup.appointment ON patient_with_age_category.p_id = vetwarmup.appointment.p_id
    JOIN vetwarmup.employee ON appointment.scheduled_by = vetwarmup.employee.e_id
    JOIN vetwarmup.qualification ON employee.e_id = vetwarmup.qualification.e_id
WHERE
    extract(year from appointment.scheduled_date) = 2024
    AND vetwarmup.qualification.qualification = 'Doctor of Veterinary Medicine (DVM)'
GROUP BY
    extract(month from vetwarmup.appointment.scheduled_date),
    patient_with_age_category.age_category
ORDER BY
    month, age;