CREATE OR REPLACE TRIGGER trg_log_reservation_4
AFTER INSERT OR UPDATE OF status ON reservation
FOR EACH ROW
BEGIN
    INSERT INTO log (reservation_id, log_date, status)
    VALUES (:NEW.reservation_id, SYSDATE, :NEW.status);
END;
/

CREATE OR REPLACE TRIGGER trg_prevent_del_res_4
BEFORE DELETE ON reservation
FOR EACH ROW
BEGIN
    RAISE_APPLICATION_ERROR(-20030, 'Zakaz usuwania rezerwacji.');
END;
/

CREATE OR REPLACE PROCEDURE p_add_reservation_4 (
    p_trip_id IN INT,
    p_person_id IN INT
)
AS
    v_trip_date DATE;
    v_max_places INT;
    v_taken_places INT;
BEGIN
    SELECT trip_date, max_no_places INTO v_trip_date, v_max_places
    FROM trip WHERE trip_id = p_trip_id;

    IF v_trip_date <= TRUNC(SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Wycieczka juz sie odbyla.');
    END IF;

    SELECT COUNT(*) INTO v_taken_places
    FROM reservation WHERE trip_id = p_trip_id AND status IN ('N', 'P');

    IF (v_max_places - v_taken_places) <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Brak wolnych miejsc.');
    END IF;

    INSERT INTO reservation (trip_id, person_id, status)
    VALUES (p_trip_id, p_person_id, 'N');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Podana wycieczka nie istnieje.');
END;
/

CREATE OR REPLACE PROCEDURE p_modify_reservation_status_4 (
    p_reservation_id IN INT,
    p_new_status IN CHAR
)
AS
    v_current_status CHAR(1);
    v_trip_id INT;
    v_max_places INT;
    v_taken_places INT;
BEGIN
    SELECT status, trip_id INTO v_current_status, v_trip_id
    FROM reservation WHERE reservation_id = p_reservation_id;

    IF v_current_status = p_new_status THEN
        RAISE_APPLICATION_ERROR(-20010, 'Rezerwacja ma juz ten status.');
    END IF;

    IF v_current_status = 'C' AND p_new_status IN ('N', 'P') THEN
        SELECT max_no_places INTO v_max_places FROM trip WHERE trip_id = v_trip_id;

        SELECT COUNT(*) INTO v_taken_places
        FROM reservation WHERE trip_id = v_trip_id AND status IN ('N', 'P');

        IF (v_max_places - v_taken_places) <= 0 THEN
            RAISE_APPLICATION_ERROR(-20011, 'Brak miejsc.');
        END IF;
    END IF;

    UPDATE reservation
    SET status = p_new_status
    WHERE reservation_id = p_reservation_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20012, 'Podana rezerwacja nie istnieje.');
END;
/

CREATE OR REPLACE PROCEDURE p_modify_max_no_places_4 (
    p_trip_id IN INT,
    p_max_no_places IN INT
)
AS
    v_taken_places INT;
    v_trip_exists INT;
BEGIN
    SELECT COUNT(*) INTO v_trip_exists FROM trip WHERE trip_id = p_trip_id;
    IF v_trip_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20020, 'Podana wycieczka nie istnieje.');
    END IF;

    SELECT COUNT(*) INTO v_taken_places
    FROM reservation WHERE trip_id = p_trip_id AND status IN ('N', 'P');

    IF p_max_no_places < v_taken_places THEN
        RAISE_APPLICATION_ERROR(-20021, 'Nie mozna zmniejszyc liczby miejsc poniżej: ' || v_taken_places);
    END IF;

    UPDATE trip
    SET max_no_places = p_max_no_places
    WHERE trip_id = p_trip_id;
END;
/