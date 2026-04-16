CREATE OR REPLACE PROCEDURE p_add_reservation (
    p_trip_id IN INT,
    p_person_id IN INT
)
AS
    v_trip_date DATE;
    v_max_places INT;
    v_taken_places INT;
    v_available_places INT;
    v_new_reservation_id INT;
BEGIN
    -- Sprawdzenie, czy wycieczka istnieje
SELECT trip_date, max_no_places
INTO v_trip_date, v_max_places
FROM trip
WHERE trip_id = p_trip_id;

-- czy wycieczka odbywa się w przyszłości
IF v_trip_date <= TRUNC(SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Wycieczka już się odbyła lub jest zaplanowana na dzisiaj.');
END IF;

    -- Sprawdzenie liczby zajętych miejsc
SELECT COUNT(*) INTO v_taken_places
FROM reservation
WHERE trip_id = p_trip_id AND status IN ('N', 'P');

v_available_places := v_max_places - v_taken_places;

    -- czy są wolne miejsca
    IF v_available_places <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Brak wolnych miejsc na tę wycieczkę.');
END IF;

    -- Dodanie rezerwacji (domyślny status 'N' dla nowej) i pobranie jej ID
INSERT INTO reservation (trip_id, person_id, status)
VALUES (p_trip_id, p_person_id, 'N')
    RETURNING reservation_id INTO v_new_reservation_id;

-- Dopisanie informacji do tabeli Log
INSERT INTO log (reservation_id, log_date, status)
VALUES (v_new_reservation_id, SYSDATE, 'N');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Podana wycieczka nie istnieje.');
END;
/




CREATE OR REPLACE PROCEDURE p_modify_reservation_status (
    p_reservation_id IN INT,
    p_new_status IN CHAR
)
AS
    v_current_status CHAR(1);
    v_trip_id INT;
    v_max_places INT;
    v_taken_places INT;
BEGIN
    -- Pobranie obecnego statusu i ID wycieczki
    SELECT status, trip_id
    INTO v_current_status, v_trip_id
    FROM reservation
    WHERE reservation_id = p_reservation_id;

    -- Sprawdzenie czy status faktycznie ulega zmianie
    IF v_current_status = p_new_status THEN
        RAISE_APPLICATION_ERROR(-20010, 'Rezerwacja ma już ten status.');
    END IF;

    -- Jeśli przywracamy rezerwację z anulowanej ('C') na aktywną ('N' lub 'P'), sprawdzamy miejsca
    IF v_current_status = 'C' AND p_new_status IN ('N', 'P') THEN
        SELECT max_no_places INTO v_max_places FROM trip WHERE trip_id = v_trip_id;

        SELECT COUNT(*) INTO v_taken_places
        FROM reservation
        WHERE trip_id = v_trip_id AND status IN ('N', 'P');

        IF (v_max_places - v_taken_places) <= 0 THEN
            RAISE_APPLICATION_ERROR(-20011, 'Brak miejsc. Nie można przywrócić anulowanej rezerwacji.');
        END IF;
    END IF;

    -- Zmiana statusu rezerwacji
    UPDATE reservation
    SET status = p_new_status
    WHERE reservation_id = p_reservation_id;

    -- Dopisanie informacji do tabeli log
    INSERT INTO log (reservation_id, log_date, status)
    VALUES (p_reservation_id, SYSDATE, p_new_status);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20012, 'Podana rezerwacja nie istnieje.');
END;
/



CREATE OR REPLACE PROCEDURE p_modify_max_no_places (
    p_trip_id IN INT,
    p_max_no_places IN INT
)
AS
    v_taken_places INT;
    v_trip_exists INT;
BEGIN
    -- Sprawdzenie czy wycieczka istnieje
    SELECT COUNT(*) INTO v_trip_exists FROM trip WHERE trip_id = p_trip_id;
    IF v_trip_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20020, 'Podana wycieczka nie istnieje.');
    END IF;

    -- Sprawdzenie aktualnie zajętych miejsc na wycieczkę
    SELECT COUNT(*) INTO v_taken_places
    FROM reservation
    WHERE trip_id = p_trip_id AND status IN ('N', 'P');

    -- czy nowa liczba miejsc nie jest mniejsza niż już zarezerwowane
    IF p_max_no_places < v_taken_places THEN
        RAISE_APPLICATION_ERROR(-20021, 'Nie można zmniejszyć liczby miejsc. Aktualna liczba aktywnych rezerwacji to: ' || v_taken_places);
    END IF;

    -- Aktualizacja liczby miejsc
    UPDATE trip
    SET max_no_places = p_max_no_places
    WHERE trip_id = p_trip_id;

END;
/