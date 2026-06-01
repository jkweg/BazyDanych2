EXPLAIN ANALYZE
SELECT date, productid, productname, value
FROM product_history_lab
WHERE date >= '2019-01-01' AND date <= '2019-01-31';


-- Utworzenie indeksu
CREATE INDEX ix_ph_date ON product_history_lab (date);

-- Sprawdzenie planu (zrób screen!)
EXPLAIN ANALYZE
SELECT date, productid, productname, value
FROM product_history_lab
WHERE date >= '2019-01-01' AND date <= '2019-01-31';

-- Usunięcie indeksu (przygotowanie do kolejnego kroku)
DROP INDEX ix_ph_date;

-- Tworzymy indeks pokrywający
CREATE INDEX ix_ph_date_incl
    ON product_history_lab (date) INCLUDE (productid, productname, value);

-- 3.1) To nasze główne zapytanie (zrób screen!)
EXPLAIN ANALYZE
SELECT date, productid, productname, value
FROM product_history_lab
WHERE date >= '2019-01-01' AND date <= '2019-01-31';

-- 3.2) Zapytanie SELECT * dla stycznia (zrób screen!)
EXPLAIN ANALYZE
SELECT * FROM product_history_lab
WHERE date >= '2019-01-01' AND date <= '2019-01-31';

-- 3.3) Zapytanie SELECT * dla całego roku (zrób screen!)
EXPLAIN ANALYZE
SELECT * FROM product_history_lab
WHERE date >= '2019-01-01' AND date <= '2019-12-31';

-- Sprzątamy
DROP INDEX ix_ph_date_incl;


-- Tworzymy zwykły indeks na próbę
CREATE INDEX ix_ph_date ON product_history_lab (date);

-- Sprawdzamy zapytanie z użyciem funkcji na kolumnie (zrób screen!)
EXPLAIN ANALYZE
SELECT date, productid, productname, value
FROM product_history_lab
WHERE EXTRACT(YEAR FROM date) = 2019 AND EXTRACT(MONTH FROM date) = 1;

DROP INDEX ix_ph_date;



