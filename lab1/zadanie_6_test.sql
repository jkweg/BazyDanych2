SELECT trip_id, max_no_places, no_available_places FROM trip WHERE trip_id = 4;

ALTER TRIGGER trg_check_places_5 DISABLE;
ALTER TRIGGER trg_reservation_places_6b DISABLE;

BEGIN
    p_add_reservation_6a(4, 2);
END;
/

SELECT trip_id, max_no_places, no_available_places FROM trip WHERE trip_id = 4;



BEGIN
    p_modify_reservation_status_6a(2, 'C');
END;
/

SELECT t.trip_id, t.max_no_places, t.no_available_places
FROM trip t
         JOIN reservation r ON t.trip_id = r.trip_id
WHERE r.reservation_id = 2;




BEGIN
    p_modify_max_no_places_6a(4, 10);
END;
/

SELECT trip_id, max_no_places, no_available_places FROM trip WHERE trip_id = 4;