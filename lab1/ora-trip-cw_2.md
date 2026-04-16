# Oracle PL/Sql

widoki, funkcje, procedury, triggery

ćwiczenie 2

(kontynuacja ćwiczenia 1)

---

Imiona i nazwiska autorów : Krystian Augustyn, Jakub Węgrzyniak

---

<style>
  {
    font-size: 16pt;
  }
</style>

<style scoped>
 li, p {
    font-size: 14pt;
  }
</style>

<style scoped>
 pre {
    font-size: 10pt;
  }
</style>

# Zadanie 6

Zmiana struktury bazy danych. W tabeli `trip` należy dodać redundantne pole `no_available_places`. Dodanie redundantnego pola uprości kontrolę dostępnych miejsc (sprawdzenie liczby dostępnych miejsc), ale nieco skomplikuje procedury dodawania rezerwacji, zmiany statusu czy też zmiany maksymalnej liczby miejsc na wycieczki (potrzebna będzie dodatkowa aktualizacja w tabeli `trip`).

Należy przygotować polecenie/procedurę przeliczającą wartość pola `no_available_places` dla wszystkich wycieczek (do jednorazowego wykonania)

Obsługę pola `no_available_places` można zrealizować przy pomocy procedur lub triggerów

Należy zwrócić uwagę na spójność rozwiązania.

> UWAGA
> Należy stworzyć nowe wersje tych widoków/procedur/triggerów (np. dodając do nazwy dopisek 6 - od numeru zadania). Poprzednie wersje procedur należy pozostawić w celu umożliwienia weryfikacji ich poprawności.

- zmiana struktury tabeli

```sql
alter table trip add
    no_available_places int null
```

- polecenie przeliczające wartość `no_available_places`
  - należy wykonać operację "przeliczenia" liczby wolnych miejsc i aktualizacji pola `no_available_places`

# Zadanie 6 - rozwiązanie



---

# Zadanie 6a - procedury

Obsługę pola `no_available_places` należy zrealizować przy pomocy procedur

- procedura dodająca rezerwację powinna aktualizować pole `no_available_places` w tabeli trip
- podobnie procedury odpowiedzialne za zmianę statusu oraz zmianę maksymalnej liczby miejsc na wycieczkę
- należy przygotować procedury oraz jeśli jest to potrzebne, zaktualizować triggery oraz widoki

> UWAGA
> Należy stworzyć nowe wersje tych widoków/procedur/triggerów (np. dodając do nazwy dopisek 6a - od numeru zadania). Poprzednie wersje procedur należy pozostawić w celu umożliwienia weryfikacji ich poprawności.

- może być potrzebne wyłączenie 'poprzednich wersji' triggerów

# Zadanie 6a - rozwiązanie

Procedura `p_add_reservation_6a`

```sql

CREATE OR REPLACE PROCEDURE p_add_reservation_6a (
    p_trip_id IN INT,
    p_person_id IN INT
)
AS
    v_trip_date DATE;
    v_available_places INT;
    v_new_reservation_id INT;
BEGIN
    -- Pobranie danych o wycieczce
SELECT trip_date, no_available_places
INTO v_trip_date, v_available_places
FROM trip
WHERE trip_id = p_trip_id;

-- Kontrola daty
IF v_trip_date <= TRUNC(SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Wycieczka już się odbyła lub jest zaplanowana na dzisiaj.');
END IF;

    -- Kontrola miejsc (teraz korzystamy z nowego pola!)
    IF v_available_places <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Brak wolnych miejsc na tę wycieczkę.');
END IF;

    -- Dodanie rezerwacji
INSERT INTO reservation (trip_id, person_id, status)
VALUES (p_trip_id, p_person_id, 'N')
  RETURNING reservation_id INTO v_new_reservation_id;

-- Aktualizacja pola w tabeli trip
UPDATE trip
SET no_available_places = no_available_places - 1
WHERE trip_id = p_trip_id;

-- Dopisanie do logu
INSERT INTO log (reservation_id, log_date, status)
VALUES (v_new_reservation_id, SYSDATE, 'N');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Podana wycieczka nie istnieje.');
END;
/


```


Procedura `p_modify_reservation_status_6a`

```sql

CREATE OR REPLACE PROCEDURE p_modify_reservation_status_6a (
    p_reservation_id IN INT,
    p_new_status IN CHAR
)
AS
    v_current_status CHAR(1);
    v_trip_id INT;
    v_available_places INT;
BEGIN
    SELECT status, trip_id
    INTO v_current_status, v_trip_id
    FROM reservation
    WHERE reservation_id = p_reservation_id;

    IF v_current_status = p_new_status THEN
        RAISE_APPLICATION_ERROR(-20010, 'Rezerwacja ma już ten status.');
    END IF;

    -- Jeśli anulujemy, zwalniamy miejsce
    IF v_current_status IN ('N', 'P') AND p_new_status = 'C' THEN
        UPDATE trip SET no_available_places = no_available_places + 1 WHERE trip_id = v_trip_id;
        -- Jeśli przywracamy, sprawdzamy i rezerwujemy miejsce
    ELSIF v_current_status = 'C' AND p_new_status IN ('N', 'P') THEN
        SELECT no_available_places INTO v_available_places FROM trip WHERE trip_id = v_trip_id;
        IF v_available_places <= 0 THEN
            RAISE_APPLICATION_ERROR(-20011, 'Brak miejsc. Nie można przywrócić anulowanej rezerwacji.');
        END IF;
        UPDATE trip SET no_available_places = no_available_places - 1 WHERE trip_id = v_trip_id;
    END IF;

    -- Zmiana statusu
    UPDATE reservation SET status = p_new_status WHERE reservation_id = p_reservation_id;

    -- Log
    INSERT INTO log (reservation_id, log_date, status) VALUES (p_reservation_id, SYSDATE, p_new_status);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20012, 'Podana rezerwacja nie istnieje.');
END;
/
```

Procedura `p_modify_max_no_places_6a`
```sql

CREATE OR REPLACE PROCEDURE p_modify_max_no_places_6a (
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

    -- czy nie zmniejszamy poniżej zera wolnych miejsc
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

```

---

# Zadanie 6b - triggery

Obsługę pola `no_available_places` należy zrealizować przy pomocy triggerów

- podczas dodawania rezerwacji trigger powinien aktualizować pole `no_available_places` w tabeli trip
- podobnie, podczas zmiany statusu rezerwacji
- należy przygotować trigger/triggery oraz jeśli jest to potrzebne, zaktualizować procedury modyfikujące dane oraz widoki

> UWAGA
> Należy stworzyć nowe wersje tych widoków/procedur/triggerów (np. dodając do nazwy dopisek 6b - od numeru zadania). Poprzednie wersje procedur należy pozostawić w celu umożliwienia weryfikacji ich poprawności.

- może być potrzebne wyłączenie 'poprzednich wersji' triggerów

# Zadanie 6b - rozwiązanie

```sql

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

```
