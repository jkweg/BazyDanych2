-- 1. 
CALL p_add_reservation_4(6, 1);


SELECT * FROM reservation ORDER BY reservation_id DESC;
SELECT * FROM log ORDER BY log_id DESC;

-- 2.
CALL p_modify_reservation_status_4(21, 'P');


SELECT * FROM log ORDER BY log_id DESC;

-- 3.
DELETE FROM reservation WHERE reservation_id = 21;

-- 4.
CALL p_modify_max_no_places_4(1, 10);
SELECT * FROM trip WHERE trip_id = 1;