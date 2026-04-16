UPDATE trip SET max_no_places = 1 WHERE trip_id = 1;
DELETE FROM reservation WHERE trip_id = 1; 
COMMIT;

CALL p_add_reservation_5(1, 1);

CALL p_add_reservation_5(1, 2);

CALL p_modify_max_no_places_5(1, 0);
