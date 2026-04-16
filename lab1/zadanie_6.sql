ALTER TABLE trip ADD no_available_places INT;

BEGIN
    FOR rec IN (SELECT trip_id, max_no_places FROM trip) LOOP
            DECLARE
                v_taken_places INT;
            BEGIN
                -- Liczymy zajęte miejsca
                SELECT COUNT(*) INTO v_taken_places
                FROM reservation
                WHERE trip_id = rec.trip_id AND status IN ('N', 'P');

                -- Aktualizujemy nową kolumnę
                UPDATE trip
                SET no_available_places = rec.max_no_places - v_taken_places
                WHERE trip_id = rec.trip_id;
            END;
        END LOOP;

    COMMIT;
END;
/
