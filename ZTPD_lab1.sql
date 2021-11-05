--1

CREATE TYPE samochod AS OBJECT (
    MARKA       VARCHAR2(20),
    MODEL       VARCHAR2(20),
    KILOMETRY   NUMBER,
    DATA_PRODUKCJI DATE,
    CENA NUMBER(10,2)
    );
    
desc samochod;
    
create table samochody of samochod;

INSERT INTO samochody values (NEW samochod('Fiat','Panda', 100000, DATE'1997-07-01', 5000));
INSERT INTO samochody values (NEW samochod('Ford','Escord', 25000, DATE'1994-07-01', 30000));
INSERT INTO samochody values (NEW samochod('Nissan','Skyline', 250000, DATE'1999-07-01', 150000));


--2

select * from samochody;

create table wlasciciele(
    imie varchar2(20),
    nazwisko varchar2(20),
    auto samochod
    );

desc wlasciciele;

INSERT INTO wlasciciele VALUES ('Kowalska','Anna',NEW samochod('Fiat','Panda', 100000, DATE'1997-07-01', 5000));
INSERT INTO wlasciciele VALUES ('Kowalski','Jan',NEW samochod('Ford','Escord', 25000, DATE'1994-07-01', 30000));


--3

select * from wlasciciele;

ALTER TYPE samochod REPLACE AS OBJECT (
    MARKA       VARCHAR2(20),
    MODEL       VARCHAR2(20),
    KILOMETRY   NUMBER,
    DATA_PRODUKCJI  DATE,
    CENA NUMBER(10,2),
    MEMBER FUNCTION wartosc return NUMBER
    );

CREATE OR REPLACE TYPE BODY samochod AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
        BEGIN
            RETURN cena*power(0.9, EXTRACT (YEAR FROM CURRENT_DATE) - EXTRACT (YEAR FROM data_produkcji));
        END wartosc;
END;


desc samochod;


SELECT s.marka, s.cena, s.wartosc() FROM samochody s;


--4

ALTER TYPE samochod ADD MAP MEMBER FUNCTION odwzoruj RETURN NUMBER CASCADE INCLUDING TABLE DATA;

create or replace type body samochod as
    MEMBER FUNCTION wartosc RETURN NUMBER IS
        BEGIN
            RETURN cena*power(0.9, EXTRACT (YEAR FROM CURRENT_DATE) - EXTRACT (YEAR FROM data_produkcji));
        END wartosc;
    
    map member function odwzoruj return number is
        begin
            return kilometry/10000 + EXTRACT (YEAR FROM CURRENT_DATE) - EXTRACT (YEAR FROM data_produkcji);
        end odwzoruj;
end;

SELECT * FROM SAMOCHODY s ORDER BY VALUE(s);


--5

CREATE TYPE wlasciciel AS OBJECT (
    IMIE       VARCHAR2(20),
    NAZWISKO       VARCHAR2(20)
    );
    
desc wlasciciel;

create table wlasciciele2 of wlasciciel;

select * from wlasciciele2;


INSERT INTO wlasciciele2 VALUES ('Anna','AnnaN');
INSERT INTO wlasciciele2 VALUES ('Jan','JanN');

ALTER TYPE samochod ADD ATTRIBUTE osoba REF wlasciciel CASCADE;

desc samochod;

UPDATE samochody s
SET s.osoba = (
    SELECT REF(w) FROM wlasciciele w
    WHERE w.imie = 'Anna' );

--=== KOLEKCJE ===

--6

SET SERVEROUTPUT ON
DECLARE
TYPE t_przedmioty IS VARRAY(10) OF VARCHAR2(20);
moje_przedmioty t_przedmioty := t_przedmioty('');
BEGIN
moje_przedmioty(1) := 'MATEMATYKA';
moje_przedmioty.EXTEND(9);
FOR i IN 2..10 LOOP
moje_przedmioty(i) := 'PRZEDMIOT_' || i;
END LOOP;
FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
END LOOP;
moje_przedmioty.TRIM(2);
FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
END LOOP;
DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
moje_przedmioty.EXTEND();
moje_przedmioty(9) := 9;
DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
moje_przedmioty.DELETE();
DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
END;

--7

SET SERVEROUTPUT ON
DECLARE
TYPE t_przedmioty IS VARRAY(10) OF VARCHAR2(20);
moje_ksiazki t_przedmioty := t_przedmioty('');
BEGIN
moje_ksiazki(1) := 'POTOP';
moje_ksiazki.EXTEND(9);
FOR i IN 2..10 LOOP
moje_ksiazki(i) := 'KSIAZKA_' || i;
END LOOP;
FOR i IN moje_ksiazki.FIRST()..moje_ksiazki.LAST() LOOP
DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
END LOOP;
moje_ksiazki.TRIM(2);
FOR i IN moje_ksiazki.FIRST()..moje_ksiazki.LAST() LOOP
DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
END LOOP;
DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_ksiazki.LIMIT());
DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_ksiazki.COUNT());
moje_ksiazki.EXTEND();
moje_ksiazki(9) := 9;
DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_ksiazki.LIMIT());
DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_ksiazki.COUNT());
moje_ksiazki.DELETE();
DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_ksiazki.LIMIT());
DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_ksiazki.COUNT());
END;

--8

DECLARE
TYPE t_wykladowcy IS TABLE OF VARCHAR2(20);
moi_wykladowcy t_wykladowcy := t_wykladowcy();
BEGIN
moi_wykladowcy.EXTEND(2);
moi_wykladowcy(1) := 'MORZY';
moi_wykladowcy(2) := 'WOJCIECHOWSKI';
moi_wykladowcy.EXTEND(8);
FOR i IN 3..10 LOOP
moi_wykladowcy(i) := 'WYKLADOWCA_' || i;
END LOOP;
FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
END LOOP;
moi_wykladowcy.TRIM(2);
FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
END LOOP;
moi_wykladowcy.DELETE(5,7);
DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
IF moi_wykladowcy.EXISTS(i) THEN
DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
END IF;
END LOOP;
moi_wykladowcy(5) := 'ZAKRZEWICZ';
moi_wykladowcy(6) := 'KROLIKOWSKI';
moi_wykladowcy(7) := 'KOSZLAJDA';
FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
IF moi_wykladowcy.EXISTS(i) THEN
DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
END IF;
END LOOP;
DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
END;

--9

DECLARE
TYPE t_miesiace IS TABLE OF VARCHAR2(20);
moje_miesiace t_miesiace := t_miesiace();
BEGIN
moje_miesiace.EXTEND(2);
moje_miesiace(1) := 'STYCZEN';
moje_miesiace(2) := 'LUTY';
moje_miesiace.EXTEND(8);
FOR i IN 3..10 LOOP
moje_miesiace(i) := 'MIESIAC_' || i;
END LOOP;
FOR i IN moje_miesiace.FIRST()..moje_miesiace.LAST() LOOP
DBMS_OUTPUT.PUT_LINE(moje_miesiace(i));
END LOOP;
moje_miesiace.TRIM(2);
FOR i IN moje_miesiace.FIRST()..moje_miesiace.LAST() LOOP
DBMS_OUTPUT.PUT_LINE(moje_miesiace(i));
END LOOP;
moje_miesiace.DELETE(5,7);
DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_miesiace.LIMIT());
DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_miesiace.COUNT());
FOR i IN moje_miesiace.FIRST()..moje_miesiace.LAST() LOOP
IF moje_miesiace.EXISTS(i) THEN
DBMS_OUTPUT.PUT_LINE(moje_miesiace(i));
END IF;
END LOOP;
moje_miesiace(5) := 'MAJ';
moje_miesiace(6) := 'CZERWIEC';
moje_miesiace(7) := 'LIPIEC';
FOR i IN moje_miesiace.FIRST()..moje_miesiace.LAST() LOOP
IF moje_miesiace.EXISTS(i) THEN
DBMS_OUTPUT.PUT_LINE(moje_miesiace(i));
END IF;
END LOOP;
DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_miesiace.LIMIT());
DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_miesiace.COUNT());
END;

--10

CREATE TYPE jezyki_obce AS VARRAY(10) OF VARCHAR2(20);
/
CREATE TYPE stypendium AS OBJECT (
nazwa VARCHAR2(50),
kraj VARCHAR2(30),
jezyki jezyki_obce );
/
CREATE TABLE stypendia OF stypendium;
INSERT INTO stypendia VALUES
('SOKRATES','FRANCJA',jezyki_obce('ANGIELSKI','FRANCUSKI','NIEMIECKI'));
INSERT INTO stypendia VALUES
('ERASMUS','NIEMCY',jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI'));
SELECT * FROM stypendia;
SELECT s.jezyki FROM stypendia s;
UPDATE STYPENDIA
SET jezyki = jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI','FRANCUSKI')
WHERE nazwa = 'ERASMUS';


CREATE TYPE lista_egzaminow AS TABLE OF VARCHAR2(20);
/
CREATE TYPE semestr AS OBJECT (
numer NUMBER,
egzaminy lista_egzaminow );
/
CREATE TABLE semestry OF semestr
NESTED TABLE egzaminy STORE AS tab_egzaminy;
INSERT INTO semestry VALUES
(semestr(1,lista_egzaminow('MATEMATYKA','LOGIKA','ALGEBRA')));
INSERT INTO semestry VALUES
(semestr(2,lista_egzaminow('BAZY DANYCH','SYSTEMY OPERACYJNE')));
SELECT s.numer, e.*
FROM semestry s, TABLE(s.egzaminy) e;
SELECT e.*
FROM semestry s, TABLE ( s.egzaminy ) e;
SELECT * FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=1 );
INSERT INTO TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 )
VALUES ('METODY NUMERYCZNE');
UPDATE TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 ) e
SET e.column_value = 'SYSTEMY ROZPROSZONE'
WHERE e.column_value = 'SYSTEMY OPERACYJNE';
DELETE FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 ) e
WHERE e.column_value = 'BAZY DANYCH';


--11

CREATE TYPE koszyk_produktow AS TABLE OF VARCHAR2(20);
/
CREATE TYPE zakupy AS OBJECT (
nazwa VARCHAR2(30),
produkty koszyk_produktow );
/
CREATE TABLE koszyki_produktow OF zakupy
NESTED TABLE produkty STORE AS tab_produkty;
INSERT INTO koszyki_produktow VALUES
(zakupy('K1',koszyk_produktow('CHELB','MASLO','SZYNKA')));
INSERT INTO koszyki_produktow VALUES
(zakupy('K2',koszyk_produktow('CIASTKO','KAWA')));

SELECT s.nazwa, e.*
FROM koszyki_produktow s, TABLE(s.produkty) e;
SELECT e.*
FROM koszyki_produktow s, TABLE ( s.produkty ) e;
SELECT * FROM TABLE ( SELECT s.produkty FROM koszyki_produktow s WHERE nazwa='K1' );
INSERT INTO TABLE ( SELECT s.produkty FROM koszyki_produktow s WHERE nazwa='K2' )
VALUES ('CUKIER');
SELECT * FROM TABLE ( SELECT s.produkty FROM koszyki_produktow s WHERE nazwa='K2' );

UPDATE TABLE ( SELECT s.produkty FROM koszyki_produktow s WHERE nazwa='K2' ) e
SET e.column_value = 'HERBATA'
WHERE e.column_value = 'KAWA';
SELECT * FROM TABLE ( SELECT s.produkty FROM koszyki_produktow s WHERE nazwa='K2' );

DELETE FROM TABLE ( SELECT s.produkty FROM koszyki_produktow s WHERE nazwa='K2' ) e
WHERE e.column_value = 'CIASTKO';


--=== POLIMORFIZM ===

--12

CREATE TYPE instrument AS OBJECT (
nazwa VARCHAR2(20),
dzwiek VARCHAR2(20),
MEMBER FUNCTION graj RETURN VARCHAR2 ) NOT FINAL;
/
CREATE TYPE BODY instrument AS
MEMBER FUNCTION graj RETURN VARCHAR2 IS
BEGIN
RETURN dzwiek;
END;
END;
/
CREATE TYPE instrument_dety UNDER instrument (
material VARCHAR2(20),
OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2,
MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 );
/
CREATE OR REPLACE TYPE BODY instrument_dety AS
OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
BEGIN
RETURN 'dmucham: '||dzwiek;
END;
MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 IS
BEGIN
RETURN glosnosc||':'||dzwiek;
END;
END;
/
CREATE TYPE instrument_klawiszowy UNDER instrument (
producent VARCHAR2(20),
OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 );
/
CREATE OR REPLACE TYPE BODY instrument_klawiszowy AS
OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
BEGIN
RETURN 'stukam w klawisze: '||dzwiek;
END;
END;
/

DECLARE
tamburyn instrument := instrument('tamburyn','brzdek-brzdek');
trabka instrument_dety := instrument_dety('trabka','tra-ta-ta','metalowa');
fortepian instrument_klawiszowy := instrument_klawiszowy('fortepian','ping-ping','steinway');
BEGIN
dbms_output.put_line(tamburyn.graj);
dbms_output.put_line(trabka.graj);
dbms_output.put_line(trabka.graj('glosno');
dbms_output.put_line(fortepian.graj);
END;


--13

CREATE TYPE istota AS OBJECT (
 nazwa VARCHAR2(20),
 NOT INSTANTIABLE MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR )
 NOT INSTANTIABLE NOT FINAL;
 
CREATE TYPE lew UNDER istota (
 liczba_nog NUMBER,
 OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR );
 
CREATE OR REPLACE TYPE BODY lew AS
 OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR IS
 BEGIN
 RETURN 'upolowana ofiara: '||ofiara;
 END;
END;

DECLARE
 KrolLew lew := lew('LEW',4);
 InnaIstota istota := istota('JAKIES ZWIERZE');
BEGIN
 DBMS_OUTPUT.PUT_LINE( KrolLew.poluj('antylopa') );
END;


--14

DECLARE
 tamburyn instrument; 
 cymbalki instrument;
 trabka instrument_dety;
 saksofon instrument_dety;
BEGIN
 tamburyn := instrument('tamburyn','brzdek-brzdek');
 cymbalki := instrument_dety('cymbalki','ding-ding','metalowe');
 trabka := instrument_dety('trabka','tra-ta-ta','metalowa');
 -- saksofon := instrument('saksofon','tra-taaaa');
 -- saksofon := TREAT( instrument('saksofon','tra-taaaa') AS instrument_dety);
END;

--
15

CREATE TABLE instrumenty OF instrument;
INSERT INTO instrumenty VALUES ( instrument('tamburyn','brzdek-brzdek') );
INSERT INTO instrumenty VALUES ( instrument_dety('trabka','tra-ta-ta','metalowa') 
);
INSERT INTO instrumenty VALUES ( instrument_klawiszowy('fortepian','pingping','steinway') );
SELECT i.nazwa, i.graj() FROM instrumenty i;


--16

CREATE TABLE PRZEDMIOTY (
 NAZWA VARCHAR2(50),
 NAUCZYCIEL NUMBER REFERENCES PRACOWNICY(ID_PRAC)
);

INSERT INTO PRZEDMIOTY VALUES ('BAZY DANYCH',100);
INSERT INTO PRZEDMIOTY VALUES ('SYSTEMY OPERACYJNE',100);
INSERT INTO PRZEDMIOTY VALUES ('PROGRAMOWANIE',110);
INSERT INTO PRZEDMIOTY VALUES ('SIECI KOMPUTEROWE',110);
INSERT INTO PRZEDMIOTY VALUES ('BADANIA OPERACYJNE',120);
INSERT INTO PRZEDMIOTY VALUES ('GRAFIKA KOMPUTEROWA',120);
INSERT INTO PRZEDMIOTY VALUES ('BAZY DANYCH',130);
INSERT INTO PRZEDMIOTY VALUES ('SYSTEMY OPERACYJNE',140);
INSERT INTO PRZEDMIOTY VALUES ('PROGRAMOWANIE',140);
INSERT INTO PRZEDMIOTY VALUES ('SIECI KOMPUTEROWE',140);
INSERT INTO PRZEDMIOTY VALUES ('BADANIA OPERACYJNE',150);
INSERT INTO PRZEDMIOTY VALUES ('GRAFIKA KOMPUTEROWA',150);
INSERT INTO PRZEDMIOTY VALUES ('BAZY DANYCH',160);
INSERT INTO PRZEDMIOTY VALUES ('SYSTEMY OPERACYJNE',160);
INSERT INTO PRZEDMIOTY VALUES ('PROGRAMOWANIE',170);
INSERT INTO PRZEDMIOTY VALUES ('SIECI KOMPUTEROWE',180);
INSERT INTO PRZEDMIOTY VALUES ('BADANIA OPERACYJNE',180);
INSERT INTO PRZEDMIOTY VALUES ('GRAFIKA KOMPUTEROWA',190);
INSERT INTO PRZEDMIOTY VALUES ('GRAFIKA KOMPUTEROWA',200);
INSERT INTO PRZEDMIOTY VALUES ('GRAFIKA KOMPUTEROWA',210);
INSERT INTO PRZEDMIOTY VALUES ('PROGRAMOWANIE',220);
INSERT INTO PRZEDMIOTY VALUES ('SIECI KOMPUTEROWE',220);
INSERT INTO PRZEDMIOTY VALUES ('BADANIA OPERACYJNE',230);


--17

CREATE TYPE ZESPOL AS OBJECT (
 ID_ZESP NUMBER,
 NAZWA VARCHAR2(50),
 ADRES VARCHAR2(100)
);
/


--18

CREATE OR REPLACE VIEW ZESPOLY_V OF ZESPOL
WITH OBJECT IDENTIFIER(ID_ZESP)
AS SELECT ID_ZESP, NAZWA, ADRES FROM ZESPOLY;


--19

CREATE TYPE PRZEDMIOTY_TAB AS TABLE OF VARCHAR2(100);
/
CREATE TYPE PRACOWNIK AS OBJECT (
 ID_PRAC NUMBER,
 NAZWISKO VARCHAR2(30),
 ETAT VARCHAR2(20),
 ZATRUDNIONY DATE,
 PLACA_POD NUMBER(10,2),
 MIEJSCE_PRACY REF ZESPOL,
 PRZEDMIOTY PRZEDMIOTY_TAB,
 MEMBER FUNCTION ILE_PRZEDMIOTOW RETURN NUMBER
);
/
CREATE OR REPLACE TYPE BODY PRACOWNIK AS
 MEMBER FUNCTION ILE_PRZEDMIOTOW RETURN NUMBER IS
 BEGIN
 RETURN PRZEDMIOTY.COUNT();
 END ILE_PRZEDMIOTOW;
END;


--20

CREATE OR REPLACE VIEW PRACOWNICY_V OF PRACOWNIK
WITH OBJECT IDENTIFIER (ID_PRAC)
AS SELECT ID_PRAC, NAZWISKO, ETAT, ZATRUDNIONY, PLACA_POD,
 MAKE_REF(ZESPOLY_V,ID_ZESP),
 CAST(MULTISET( SELECT NAZWA FROM PRZEDMIOTY WHERE NAUCZYCIEL=P.ID_PRAC ) AS 
PRZEDMIOTY_TAB )
FROM PRACOWNICY P;


--21

SELECT * FROM PRACOWNICY_V;

SELECT P.NAZWISKO, P.ETAT, P.MIEJSCE_PRACY.NAZWA
FROM PRACOWNICY_V P;

SELECT P.NAZWISKO, P.ILE_PRZEDMIOTOW()
FROM PRACOWNICY_V P;

SELECT *
FROM TABLE( SELECT PRZEDMIOTY FROM PRACOWNICY_V WHERE NAZWISKO='WEGLARZ' );

SELECT NAZWISKO, CURSOR( SELECT PRZEDMIOTY
FROM PRACOWNICY_V
WHERE ID_PRAC=P.ID_PRAC)
FROM PRACOWNICY_V P;


--22

CREATE TYPE pisarz AS OBJECT (
    id_pisarza NUMBER,
    nazwisko VARCHAR2(20),
    data_ur DATE,
    KSIAZKI ksiazki_t,
    MEMBER FUNCTION ILE_KSIAZEK RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY PISARZ AS
    MEMBER FUNCTION ILE_KSIAZEK RETURN NUMBER IS
    BEGIN
        RETURN KSIAZKI.COUNT();
    END ILE_KSIAZEK;
END;

CREATE TYPE KSIAZKA AS OBJECT (
    id_ksiazki NUMBER,
    autor ref pisarz,
    tytul VARCHAR2(50),
    data_wydania DATE,
    MEMBER FUNCTION WIEK RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY KSIAZKA AS
    MEMBER FUNCTION WIEK RETURN NUMBER IS
    BEGIN
        RETURN EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM DATA_WYDANIA);
    END WIEK;
END;

CREATE OR REPLACE VIEW KSIAZKI_VIEW OF KSIAZKA
WITH OBJECT IDENTIFIER(id_ksiazki)
AS SELECT id_ksiazki, MAKE_REF(PISARZE_VIEW, id_pisarza), tytul, data_wydania FROM KSIAZKI;

CREATE OR REPLACE VIEW PISARZE_VIEW OF PISARZ
WITH OBJECT IDENTIFIER(id_pisarza)
AS SELECT id_pisarza, nazwisko, data_ur, CAST(MULTISET(SELECT tytul FROM KSIAZKI WHERE id_pisarza=P.id_pisarza) AS ksiazki_t) FROM PISARZE P;


--23

CREATE TYPE auto_osobowe UNDER AUTO (
    liczba_miejsc NUMBER,
    klimatyzacja VARCHAR2(3),
    OVERRIDING MEMBER FUNCTION wartosc RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY auto_osobowe AS
    OVERRIDING MEMBER FUNCTION wartosc RETURN NUMBER IS
        wartosc NUMBER;
    BEGIN
        wartosc := (SELF AS AUTO).wartosc();
        IF (klimatyzacja = 'TAK') THEN
            wartosc := wartosc * 1.5;
        END IF;
        RETURN wartosc;
    END;
END;

CREATE TYPE AUTO_CIEZAROWE UNDER AUTO (
    max_ladownosc NUMBER,
    OVERRIDING MEMBER FUNCTION wartosc RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY AUTO_CIEZAROWE AS
    OVERRIDING MEMBER FUNCTION wartosc RETURN NUMBER IS
        wartosc NUMBER;
    BEGIN
        wartosc := (SELF AS AUTO).wartosc();
        IF (max_ladownosc > 10000) THEN
            WARTOSC := wartosc * 2;
        END IF;
        RETURN wartosc;
    END;
END;

INSERT INTO AUTA VALUES (AUTO_OSOBOWE('Ford', 'Focus', 20000, DATE '2012-01-01', 50000, 5, 'TAK'));
INSERT INTO AUTA VALUES (AUTO_OSOBOWE('Wolkswagen', 'Golf', 40000, DATE '2006-11-22', 10000, 5, 'NIE'));
INSERT INTO AUTA VALUES (AUTO_CIEZAROWE('Volvo', 'TIR', 800000, DATE '2015-01-21', 200000, 10000));
INSERT INTO AUTA VALUES (AUTO_CIEZAROWE('Mercedes', 'Ciezarowy', 120000, DATE '2018-11-22', 250000, 15000));

SELECT A.MARKA, A.WARTOSC() FROM AUTA A;