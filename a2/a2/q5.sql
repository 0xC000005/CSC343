-- Assignment 2 Query 5

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO A2VetClinic;
DROP TABLE IF EXISTS q5 CASCADE;

CREATE TABLE q5
(
    p_id        INT NOT NULL,
    num_complex INT NOT NULL
);

-- An appointment is considered “complex” if it takes more than twice the average amount of time taken for
-- appointments for patients of the same species. A patient is considered “complex” if they have at least one
-- complex appointment.
-- Find the complex patient(s) that has had the most complex appointments and how many complex appointments
-- they had. If no patients are complex, then all patients should be reported with 0 (not NULL) as the number
-- of complex appointments.


-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
-- If you do not define any views, you can delete the lines about views.
DROP VIEW IF EXISTS avg_time_per_specie CASCADE;
DROP VIEW IF EXISTS complex_appointments CASCADE;
DROP VIEW IF EXISTS most_complex_patient CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW avg_time_per_specie AS
SELECT patient.species, AVG(end_time - start_time) as avg_time
FROM appointment
         JOIN patient ON appointment.p_id = patient.p_id
GROUP BY patient.species
ORDER BY avg_time DESC;


CREATE VIEW complex_appointments AS
SELECT appointment.a_id, patient.p_id, patient.species, end_time - start_time as time
FROM appointment
         JOIN patient ON appointment.p_id = patient.p_id
WHERE end_time - start_time >
      2 * (SELECT avg_time FROM avg_time_per_specie WHERE avg_time_per_specie.species = patient.species);


CREATE VIEW most_complex_patient AS
WITH patient_with_complex_appointment_counts AS (SELECT patient.p_id, COUNT(complex_appointments.a_id) as num_complex
                                                 FROM complex_appointments
                                                          JOIN patient ON complex_appointments.p_id = patient.p_id
                                                 GROUP BY patient.p_id
                                                 ORDER BY num_complex DESC)
SELECT p_id, num_complex
FROM patient_with_complex_appointment_counts
WHERE num_complex = (SELECT MAX(num_complex) FROM patient_with_complex_appointment_counts);


-- Your query that answers the question goes below the "insert into" line:
-- If there is no value in the most_complex_patient view, then we will insert all patients with 0 as the number of complex appointments
INSERT INTO q5
SELECT p.p_id, COALESCE(mcp.num_complex, 0) AS num_complex
FROM patient p
LEFT JOIN most_complex_patient mcp ON p.p_id = mcp.p_id
WHERE mcp.p_id IS NOT NULL
   OR NOT EXISTS (SELECT 1 FROM most_complex_patient)
ORDER BY num_complex DESC, p.p_id;

-- Query to view final results in q5 table
