-- Warmup Query 2

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO VetWarmup;
DROP TABLE IF EXISTS wu2 cascade;

CREATE TABLE wu2 (
    p_id INT NOT NULL,
    num_appts INT NOT NULL
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
INSERT INTO wu2
SELECT high_needs_patients.p_id,  COALESCE(COUNT(appointment.a_id), 0)  AS num_appointments
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




