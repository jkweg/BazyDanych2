
CREATE OR REPLACE TRIGGER trg_check_places_5
BEFORE INSERT OR UPDATE OF status ON reservation
FOR EACH ROW
DECLARE
    -- Autonomiczna transakcja pozwala odpytać tabelę, na której właśnie trwają zmiany
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_avail INT;
BEGIN
    
    IF :NEW.status IN ('N', 'P') THEN
        SELECT max_no_places - (
            SELECT COUNT(*) FROM reservation 
            WHERE trip_id = :NEW.trip_id AND status IN ('N', 'P')
        ) INTO v_avail FROM trip WHERE trip_id = :NEW.trip_id;

        IF v_avail <= 0 THEN
            RAISE_APPLICATION_ERROR(-20050, 'Brak wolnych miejsc na te wycieczke.');
        END IF;
    END IF;
    COMMIT; 
END;
/


CREATE OR REPLACE PROCEDURE p_add_reservation_5(p_trip INT, p_person INT) AS
BEGIN
    INSERT INTO reservation(trip_id, person_id, status) VALUES (p_trip, p_person, 'N');
    COMMIT;
END;
/


CREATE OR REPLACE PROCEDURE p_modify_reservation_status_5(p_res INT, p_stat CHAR) AS
BEGIN
    UPDATE reservation SET status = p_stat WHERE reservation_id = p_res;
    COMMIT;
END;
/


CREATE OR REPLACE PROCEDURE p_modify_max_no_places_5 (p_trip_id IN INT, p_max_no_places IN INT) AS
    v_taken_places INT;
BEGIN
    SELECT COUNT(*) INTO v_taken_places
    FROM reservation WHERE trip_id = p_trip_id AND status IN ('N', 'P');

    IF p_max_no_places < v_taken_places THEN
        RAISE_APPLICATION_ERROR(-20021, 'Nie mozna zmniejszyc liczby miejsc ponizej: ' || v_taken_places);
    END IF;

    UPDATE trip SET max_no_places = p_max_no_places WHERE trip_id = p_trip_id;
    COMMIT;
END;
/