CREATE OR REPLACE TRIGGER trg_reservation_places_6b
AFTER INSERT OR UPDATE OF status ON reservation
    FOR EACH ROW
BEGIN
    -- Obsługa dodania nowej rezerwacji
    IF INSERTING THEN
        IF :NEW.status IN ('N', 'P') THEN
UPDATE trip SET no_available_places = no_available_places - 1 WHERE trip_id = :NEW.trip_id;
END IF;
END IF;

    -- Obsługa zmiany statusu
    IF UPDATING THEN
        -- Anulowanie rezerwacji
        IF :OLD.status IN ('N', 'P') AND :NEW.status = 'C' THEN
UPDATE trip SET no_available_places = no_available_places + 1 WHERE trip_id = :NEW.trip_id;
-- Przywrócenie rezerwacji - zajęcie miejsca
ELSIF :OLD.status = 'C' AND :NEW.status IN ('N', 'P') THEN
UPDATE trip SET no_available_places = no_available_places - 1 WHERE trip_id = :NEW.trip_id;
END IF;
END IF;
END;
/





CREATE OR REPLACE PROCEDURE p_add_reservation_6b (
    p_trip_id IN INT,
    p_person_id IN INT
)
AS
    v_trip_date DATE;
    v_available_places INT;
BEGIN
    SELECT trip_date, no_available_places INTO v_trip_date, v_available_places
    FROM trip WHERE trip_id = p_trip_id;

    IF v_trip_date <= TRUNC(SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Wycieczka już się odbyła lub jest zaplanowana na dzisiaj.');
    END IF;

    IF v_available_places <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Brak wolnych miejsc na tę wycieczkę.');
    END IF;

    INSERT INTO reservation (trip_id, person_id, status)
    VALUES (p_trip_id, p_person_id, 'N');


EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Podana wycieczka nie istnieje.');
END;
/

CREATE OR REPLACE PROCEDURE p_modify_reservation_status_6b (
    p_reservation_id IN INT,
    p_new_status IN CHAR
)
AS
    v_current_status CHAR(1);
    v_trip_id INT;
    v_available_places INT;
BEGIN
    SELECT status, trip_id INTO v_current_status, v_trip_id
    FROM reservation WHERE reservation_id = p_reservation_id;

    IF v_current_status = p_new_status THEN
        RAISE_APPLICATION_ERROR(-20010, 'Rezerwacja ma już ten status.');
    END IF;

    IF v_current_status = 'C' AND p_new_status IN ('N', 'P') THEN
        SELECT no_available_places INTO v_available_places FROM trip WHERE trip_id = v_trip_id;
        IF v_available_places <= 0 THEN
            RAISE_APPLICATION_ERROR(-20011, 'Brak miejsc. Nie można przywrócić anulowanej rezerwacji.');
        END IF;
    END IF;

    UPDATE reservation SET status = p_new_status WHERE reservation_id = p_reservation_id;


EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20012, 'Podana rezerwacja nie istnieje.');
END;
/

CREATE OR REPLACE PROCEDURE p_modify_max_no_places_6b (
    p_trip_id IN INT,
    p_max_no_places IN INT
)
AS
    v_current_max INT;
    v_available_places INT;
    v_difference INT;
BEGIN
    SELECT max_no_places, no_available_places
    INTO v_current_max, v_available_places
    FROM trip WHERE trip_id = p_trip_id;

    v_difference := p_max_no_places - v_current_max;

    IF (v_available_places + v_difference) < 0 THEN
        RAISE_APPLICATION_ERROR(-20021, 'Nie można zmniejszyć liczby miejsc poniżej liczby aktywnych rezerwacji.');
    END IF;

    UPDATE trip
    SET max_no_places = p_max_no_places,
        no_available_places = no_available_places + v_difference
    WHERE trip_id = p_trip_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20020, 'Podana wycieczka nie istnieje.');
END;
/