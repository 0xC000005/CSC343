-- Assignment 2 Query 3

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO A2VetClinic;
DROP TABLE IF EXISTS q3 CASCADE;

CREATE TABLE q3
(
    e_id        INT      NOT NULL,
    time_worked INTERVAL NOT NULL
);


-- Assume that the number of hours an employee works in a day is defined by the start time and end times of the
-- appointments they work. For example, if an employee works on three appointments in the same day, one from
-- 9:00-10:30, one from 10:30-10:45, and one from 13:30-14:30, then they have worked a total of 2.75 hours that
-- day, in two consecutive blocks of 1.75 and 1 hours respectively. You can assume that there are no overlapping
-- appointments for an employee, and we do not consider appointments like 9:00-10:30 and 10:30-10:45 to be
-- overlapping.
-- We’ll define an “exhausting day” as a day where the employee worked a total of 8 consecutive hours or more.
-- Find all vet techs (RVTs) who had a least three weeks with at least two exhausting days per week. A week is
-- defined as Monday to Friday, inclusive. Report the employee IDs and their total interval worked.

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
-- If you do not define any views, you can delete the lines about views.
DROP VIEW IF EXISTS employee_worked_over_8_hours_in_that_day CASCADE;
DROP VIEW IF EXISTS employee_worked_over_8_hours_in_that_day_plus_previous_end_time CASCADE;
DROP VIEW IF EXISTS employee_worked_over_8_hours_in_that_day_plus_time_blocks CASCADE;
DROP VIEW IF EXISTS employee_worked_on_exhausting_days CASCADE;
DROP VIEW IF EXISTS employee_exhausted_week CASCADE;

CREATE VIEW employee_worked_over_8_hours_in_that_day AS
WITH distinct_employee_appointment AS
         (SELECT DISTINCT scheduled_date, e.e_id, appointment.a_id
          FROM a2vetclinic.appointment
                   JOIN scheduledprocedurestaff ON appointment.a_id = scheduledprocedurestaff.a_id
                   JOIN a2vetclinic.employee e ON scheduledprocedurestaff.e_id = e.e_id
          ORDER BY scheduled_date, e.e_id)
SELECT appointment.scheduled_date,
       distinct_employee_appointment.e_id,
       SUM(end_time - start_time) as time_worked
FROM distinct_employee_appointment
         JOIN a2vetclinic.appointment appointment ON distinct_employee_appointment.a_id = appointment.a_id
GROUP BY appointment.scheduled_date, distinct_employee_appointment.e_id
HAVING SUM(end_time - start_time) >= '8 hours'
ORDER BY appointment.scheduled_date, distinct_employee_appointment.e_id;


CREATE VIEW employee_worked_over_8_hours_in_that_day_plus_previous_end_time AS
SELECT DISTINCT ON (appt.scheduled_date, e.e_id, appt.start_time) appt.scheduled_date,
                                                                  e.e_id,
                                                                  appt.start_time,
                                                                  appt.end_time,
                                                                  LAG(appt.end_time)
                                                                  OVER (PARTITION BY appt.scheduled_date, e.e_id ORDER BY appt.start_time)
                                                                      AS prev_end_time
FROM appointment appt
         JOIN scheduledprocedurestaff sps ON appt.a_id = sps.a_id
         JOIN employee e ON sps.e_id = e.e_id
         JOIN employee_worked_over_8_hours_in_that_day e_8
              ON appt.scheduled_date = e_8.scheduled_date AND e.e_id = e_8.e_id;


CREATE VIEW employee_worked_over_8_hours_in_that_day_plus_time_blocks AS
WITH appointment_blocks AS (SELECT scheduled_date,
                                   e_id,
                                   start_time,
                                   end_time,
                                   prev_end_time,
                                   (start_time - prev_end_time) AS time_diff,
                                   CASE
                                       WHEN prev_end_time IS NULL OR start_time > prev_end_time THEN 1
                                       ELSE 0
                                       END                      AS new_block
                            FROM employee_worked_over_8_hours_in_that_day_plus_previous_end_time)
SELECT *, SUM(new_block) OVER (PARTITION BY scheduled_date, e_id ORDER BY start_time) AS block_num
FROM appointment_blocks;


CREATE VIEW employee_worked_on_exhausting_days AS
SELECT scheduled_date, e_id
FROM employee_worked_over_8_hours_in_that_day_plus_time_blocks
GROUP BY scheduled_date, e_id, block_num
HAVING SUM(end_time - start_time) >= '8 hours';


CREATE VIEW employee_exhausted_week AS
SELECT e_id,
       date_trunc('week', scheduled_date)::date AS week_start,
       COUNT(*)                                 AS exhausting_days_count
FROM employee_worked_on_exhausting_days
GROUP BY e_id, week_start;


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q3
SELECT e.e_id,
       SUM(a.end_time - a.start_time) AS time_worked
FROM employee e
         JOIN scheduledprocedurestaff sps ON e.e_id = sps.e_id
         JOIN appointment a ON sps.a_id = a.a_id
         JOIN qualification q ON e.e_id = q.e_id
WHERE q.qualification LIKE '%RVT%'
  AND e.e_id IN (
    SELECT e_id
    FROM employee_exhausted_week
    WHERE exhausting_days_count >= 2
    GROUP BY e_id
    HAVING COUNT(*) >= 3
  )
GROUP BY e.e_id;
