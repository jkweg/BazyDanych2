
ALTER TRIGGER trg_log_reservation_4 DISABLE;


ALTER TRIGGER trg_check_places_5 DISABLE;

SELECT trip_id, trip_name, max_no_places, no_available_places
FROM trip
WHERE trip_id = 2;

UPDATE trip
SET NO_AVAILABLE_PLACES = 1
WHERE trip_id = 2;
COMMIT;

BEGIN
    p_add_reservation_6b(2, 3);
COMMIT;
END;
/

SELECT * FROM reservation ORDER BY reservation_id DESC;