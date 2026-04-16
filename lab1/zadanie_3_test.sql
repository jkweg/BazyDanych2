BEGIN
    p_add_reservation(4, 3);
END;
/

SELECT * FROM reservation WHERE trip_id = 4 AND person_id = 3;
SELECT * FROM log;

BEGIN

    p_add_reservation(1, 1);
END;
/


BEGIN
    p_modify_reservation_status(2, 'P');
END;
/

SELECT * FROM reservation WHERE reservation_id = 2;
SELECT * FROM log WHERE reservation_id = 2;


BEGIN
    p_modify_max_no_places(2, 0);
END;
/
