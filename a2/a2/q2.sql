-- Assignment 2 Query 2

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO A2VetClinic;
DROP TABLE IF EXISTS q2 CASCADE;

CREATE TABLE q2
(
    e_id                INT         NOT NULL,
    name                VARCHAR(30) NOT NULL,
    hire_year           INT         NOT NULL,
    num_appointments    INT         NOT NULL,
    days_worked         INT         NOT NULL,
    avg_appointment_len INTERVAL    NOT NULL,
    clients_helped      INT         NOT NULL,
    patients_helped     INT         NOT NULL,
    num_coworkers       INT         NOT NULL,
    total_supplies      INT         NOT NULL
);

-- Generate a summary of employee activity over all time represented in the database. For every employee
-- in the clinic, generate the information in the following tables. For every value below, report 0 or 0.0 (not
-- NULL) for missing data, unless explicitly specified otherwise. Assume that an employee has “worked with” a
-- client/patient/another employee if they were scheduled for the same appointment. You will likely find COALESCE
-- useful here.

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
-- If you do not define any views, you can delete the lines about views.
DROP VIEW IF EXISTS employee_num_appointments CASCADE;
DROP VIEW IF EXISTS employee_num_days_worked CASCADE;
DROP VIEW IF EXISTS employee_avg_appointment_len CASCADE;
DROP VIEW IF EXISTS employee_clients_helped CASCADE;
DROP VIEW IF EXISTS employee_patients_helped CASCADE;
DROP VIEW IF EXISTS employee_num_coworkers CASCADE;
DROP VIEW IF EXISTS employee_total_supplies CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW employee_num_appointments AS
WITH employee_num_appointments_not_complete AS
         (SELECT DISTINCT employee.e_id, COUNT(DISTINCT appointment.a_id)
          FROM employee
                   JOIN scheduledprocedurestaff ON employee.e_id = scheduledprocedurestaff.e_id
                   JOIN appointment ON scheduledprocedurestaff.a_id = appointment.a_id
          GROUP BY employee.e_id
          ORDER BY employee.e_id)
SELECT employee.e_id, COALESCE(employee_num_appointments_not_complete.count, 0) AS count
FROM employee
         LEFT JOIN employee_num_appointments_not_complete ON employee.e_id = employee_num_appointments_not_complete.e_id
ORDER BY employee.e_id;


-- the number of day worked is the distinct appointment date
CREATE VIEW employee_num_days_worked AS
SELECT employee.e_id, COUNT(DISTINCT a.scheduled_date) AS days_worked
FROM employee
         JOIN scheduledprocedurestaff ON employee.e_id = scheduledprocedurestaff.e_id
         JOIN appointment a on a.a_id = scheduledprocedurestaff.a_id
group by employee.e_id
ORDER BY e_id;


-- CREATE VIEW employee_avg_appointment_len AS
-- WITH employee_avg_appointment_len_not_complete AS
--          (SELECT employee.e_id, AVG(appointment.end_time - appointment.start_time) AS avg_appointment_len
--           FROM employee
--                    JOIN scheduledprocedurestaff ON employee.e_id = scheduledprocedurestaff.e_id
--                    JOIN appointment ON scheduledprocedurestaff.a_id = appointment.a_id
--           GROUP BY employee.e_id
--           ORDER BY employee.e_id)
-- SELECT employee.e_id,
--        COALESCE(employee_avg_appointment_len_not_complete.avg_appointment_len, INTERVAL '0 hours') AS avg_duration
-- FROM employee
--          LEFT JOIN employee_avg_appointment_len_not_complete
--                    ON employee.e_id = employee_avg_appointment_len_not_complete.e_id
-- ORDER BY employee.e_id;


CREATE OR REPLACE VIEW employee_avg_appointment_len AS
WITH employee_appointment_durations AS (SELECT DISTINCT e.e_id,
                                                        a.a_id,
                                                        a.scheduled_date,
                                                        a.end_time - a.start_time AS appointment_duration
                                        FROM employee e
                                                 LEFT JOIN scheduledprocedurestaff sps ON e.e_id = sps.e_id
                                                 LEFT JOIN appointment a ON sps.a_id = a.a_id
                                        WHERE a.scheduled_date <= CURRENT_DATE -- Only consider appointments up to the current date
)
SELECT e.e_id,
       COALESCE(
               AVG(ead.appointment_duration),
               INTERVAL '0 hours'
       ) AS avg_duration
FROM employee e
         LEFT JOIN employee_appointment_durations ead ON e.e_id = ead.e_id
GROUP BY e.e_id
ORDER BY e.e_id;


WITH employee_appointment_durations AS (SELECT DISTINCT ON (e.e_id, a.a_id)
                                            e.e_id,
                                                        a.a_id,
                                                        a.scheduled_date,
                                                        a.end_time - a.start_time AS appointment_duration
                                        FROM employee e
                                                 JOIN scheduledprocedurestaff sps ON e.e_id = sps.e_id
                                                 JOIN appointment a ON sps.a_id = a.a_id
                                        WHERE a.scheduled_date <= CURRENT_DATE
                                          AND e.e_id = 7)
SELECT e.e_id,
       COALESCE(
               AVG(ead.appointment_duration),
               INTERVAL '0 hours'
       ) AS avg_duration
FROM employee e
         LEFT JOIN employee_appointment_durations ead ON e.e_id = ead.e_id
GROUP BY e.e_id
ORDER BY e.e_id;


WITH employee_appointment_durations AS (
    SELECT DISTINCT ON (e.e_id, a.a_id)
        e.e_id,
        a.end_time - a.start_time AS appointment_duration
    FROM
        employee e
    JOIN scheduledprocedurestaff sps ON e.e_id = sps.e_id
    JOIN appointment a ON sps.a_id = a.a_id
    WHERE a.scheduled_date <= CURRENT_DATE
        AND e.e_id = 7
)
SELECT
    e.e_id,
    COALESCE(
        AVG(ead.appointment_duration),
        INTERVAL '0 hours'
    ) AS avg_appointment_len
FROM
    employee e
LEFT JOIN employee_appointment_durations ead ON e.e_id = ead.e_id
GROUP BY e.e_id
ORDER BY e.e_id;



CREATE VIEW employee_clients_helped AS
WITH employee_clients_helped_not_complete AS
         (SELECT employee.e_id, COUNT(DISTINCT client.c_id) AS clients_helped
          FROM employee
                   JOIN scheduledprocedurestaff ON employee.e_id = scheduledprocedurestaff.e_id
                   JOIN appointment ON scheduledprocedurestaff.a_id = appointment.a_id
                   JOIN patient ON appointment.p_id = patient.p_id
                   JOIN client ON patient.c_id = client.c_id
          GROUP BY employee.e_id
          ORDER BY employee.e_id)
SELECT employee.e_id, COALESCE(employee_clients_helped_not_complete.clients_helped, 0) AS clients_helped
FROM employee
         LEFT JOIN employee_clients_helped_not_complete ON employee.e_id = employee_clients_helped_not_complete.e_id
ORDER BY employee.e_id;


CREATE VIEW employee_patients_helped AS
SELECT employee.e_id, COUNT(DISTINCT appointment.p_id) AS patients_helped
FROM employee
         JOIN scheduledprocedurestaff ON employee.e_id = scheduledprocedurestaff.e_id
         JOIN appointment ON scheduledprocedurestaff.a_id = appointment.a_id
GROUP BY employee.e_id;


CREATE VIEW employee_num_coworkers AS
WITH employee_num_coworkers_not_complete AS
         (WITH employee_appointments AS (SELECT DISTINCT a_id, e_id
                                         FROM scheduledprocedurestaff)
          SELECT e1.e_id                 AS employee_id,
                 COUNT(DISTINCT e2.e_id) AS unique_coworkers
          FROM employee_appointments e1
                   JOIN
               employee_appointments e2 ON e1.a_id = e2.a_id AND e1.e_id != e2.e_id
          GROUP BY e1.e_id
          ORDER BY e1.e_id)
SELECT employee.e_id, COALESCE(employee_num_coworkers_not_complete.unique_coworkers, 0) AS unique_coworkers
FROM employee
         LEFT JOIN employee_num_coworkers_not_complete
                   ON employee.e_id = employee_num_coworkers_not_complete.employee_id
ORDER BY employee.e_id;


CREATE VIEW employee_total_supplies AS
WITH employee_total_supplies_not_complete AS
         (SELECT e_id, SUM(quantity) AS total_supplies
          FROM scheduledprocedurestaff
                   JOIN proceduresupply ON scheduledprocedurestaff.pr_id = proceduresupply.pr_id
          GROUP BY e_id)
SELECT employee.e_id, COALESCE(employee_total_supplies_not_complete.total_supplies, 0) AS total_supplies
FROM employee
         LEFT JOIN employee_total_supplies_not_complete ON employee.e_id = employee_total_supplies_not_complete.e_id
ORDER BY employee.e_id;


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q2
SELECT employee.e_id,
       employee.name,
       EXTRACT(YEAR FROM employee.start_date)                                  AS hire_year,
       COALESCE(employee_num_appointments.count, 0)                            AS num_appointments,
       COALESCE(employee_num_days_worked.days_worked, 0)                       AS days_worked,
       COALESCE(employee_avg_appointment_len.avg_duration, INTERVAL '0 hours') AS avg_appointment_len,
       COALESCE(employee_clients_helped.clients_helped, 0)                     AS clients_helped,
       COALESCE(employee_patients_helped.patients_helped, 0)                   AS patients_helped,
       COALESCE(employee_num_coworkers.unique_coworkers, 0)                    AS num_coworkers,
       COALESCE(employee_total_supplies.total_supplies, 0)                     AS total_supplies
FROM employee
         LEFT JOIN employee_num_appointments ON employee.e_id = employee_num_appointments.e_id
         LEFT JOIN employee_num_days_worked ON employee.e_id = employee_num_days_worked.e_id
         LEFT JOIN employee_avg_appointment_len ON employee.e_id = employee_avg_appointment_len.e_id
         LEFT JOIN employee_clients_helped ON employee.e_id = employee_clients_helped.e_id
         LEFT JOIN employee_patients_helped ON employee.e_id = employee_patients_helped.e_id
         LEFT JOIN employee_num_coworkers ON employee.e_id = employee_num_coworkers.e_id
         LEFT JOIN employee_total_supplies ON employee.e_id = employee_total_supplies.e_id
ORDER BY employee.e_id;

