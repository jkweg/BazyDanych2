CREATE OR REPLACE FUNCTION f_trip_participants(p_trip_id INT) RETURN SYS_REFCURSOR IS
    v_rc SYS_REFCURSOR;
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM trip WHERE trip_id = p_trip_id;
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Błąd: Wycieczka o podanym ID nie istnieje.');
    END IF;

    OPEN v_rc FOR 
        SELECT * FROM vw_reservation WHERE trip_id = p_trip_id;
    RETURN v_rc;
END;
/

CREATE OR REPLACE FUNCTION f_person_reservations(p_person_id INT) RETURN SYS_REFCURSOR IS
    v_rc SYS_REFCURSOR;
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM person WHERE person_id = p_person_id;
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Błąd: Osoba o podanym ID nie istnieje.');
    END IF;

    OPEN v_rc FOR 
        SELECT * FROM vw_reservation WHERE person_id = p_person_id;
    RETURN v_rc;
END;
/

CREATE OR REPLACE FUNCTION f_available_trips_to(
    p_country VARCHAR2, 
    p_date_from DATE, 
    p_date_to DATE
) RETURN SYS_REFCURSOR IS
    v_rc SYS_REFCURSOR;
BEGIN
    IF p_date_from > p_date_to THEN
        RAISE_APPLICATION_ERROR(-20003, 'Błąd: Data początkowa nie może być późniejsza niż data końcowa.');
    END IF;

    OPEN v_rc FOR 
        SELECT * FROM vw_available_trip 
        WHERE country = p_country 
          AND trip_date BETWEEN p_date_from AND p_date_to;
    RETURN v_rc;
END;
/