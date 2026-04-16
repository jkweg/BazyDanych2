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