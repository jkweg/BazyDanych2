CREATE OR REPLACE VIEW vw_reservation AS
SELECT
    r.reservation_id,
    t.country,
    t.trip_date,
    t.trip_name,
    p.firstname,
    p.lastname,
    r.status,
    t.trip_id,
    p.person_id
FROM reservation AS r
         JOIN trip AS t ON r.trip_id = t.trip_id
         JOIN person AS p ON r.person_id = p.person_id;

CREATE OR REPLACE VIEW vw_trip AS
SELECT
    t.trip_id,
    t.country,
    t.trip_date,
    t.trip_name,
    t.max_no_places,
    (t.max_no_places - (SELECT COUNT(*)
                        FROM reservation r
                        WHERE r.trip_id = t.trip_id
                          AND r.status != 'C')) AS no_available_places
FROM trip t;


CREATE OR REPLACE VIEW vw_available_trip AS
SELECT *
FROM vw_trip
WHERE trip_date > CURRENT_DATE AND no_available_places > 0;

