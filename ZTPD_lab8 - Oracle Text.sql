--1

CREATE TABLE CYTATY AS SELECT * FROM ZSBD_TOOLS.CYTATY;

SELECT * FROM CYTATY;


--2

SELECT AUTOR, TEKST
FROM CYTATY
WHERE
    UPPER(TEKST) LIKE '%PESYMISTA%'
    AND UPPER(TEKST) LIKE '%OPTYMISTA%';


--3

CREATE INDEX CYTATY_TEKST_IDX
ON CYTATY(TEKST)
INDEXTYPE IS CTXSYS.CONTEXT;


--4

SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'PESYMISTA AND OPTYMISTA', 1) > 0;


--5

SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'PESYMISTA ~ OPTYMISTA', 1) > 0;


--6

SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'NEAR((PESYMISTA, OPTYMISTA), 3)') > 0;


--7

SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'NEAR((PESYMISTA, OPTYMISTA), 10)') > 0;


--8

SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, '�yci%', 1) > 0;


--9

SELECT 
    AUTOR, 
    TEKST, 
    SCORE(1) AS DOPASOWANIE
FROM CYTATY
WHERE CONTAINS(TEKST, '�yci%', 1) > 0;


--10

SELECT 
    AUTOR, 
    TEKST, 
    SCORE(1) AS DOPASOWANIE
FROM CYTATY
WHERE CONTAINS(TEKST, '�yci%', 1) > 0 AND ROWNUM <= 1
ORDER BY 3 DESC;


--11

SELECT
    AUTOR,
    TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'FUZZY(probelm)', 1) > 0;


--12

INSERT INTO CYTATY VALUES(
    1000,
    'Bertrand Russell',
    'To smutne, �e g�upcy s� tacy pewni siebie, a ludzie rozs�dni tacy pe�ni w�tpliwo�ci.'
);

COMMIT;


--13

SELECT
    AUTOR,
    TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'g�upcy', 1) > 0;


--14

SELECT TOKEN_TEXT
FROM DR$CYTATY_TEKST_IDX$I;

SELECT TOKEN_TEXT
FROM DR$CYTATY_TEKST_IDX$I
WHERE TOKEN_TEXT = 'g�upcy';


--15

DROP INDEX CYTATY_TEKST_IDX;

CREATE INDEX CYTATY_TEKST_IDX
ON CYTATY(TEKST)
INDEXTYPE IS CTXSYS.CONTEXT;


--16

SELECT
    AUTOR,
    TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'g�upcy', 1) > 0;


--17

DROP INDEX CYTATY_TEKST_IDX;

DROP TABLE CYTATY;


--Zaawansowane indeksowanie i wyszukiwanie
--1

CREATE TABLE QUOTES AS SELECT * FROM ZSBD_TOOLS.QUOTES;

SELECT * FROM QUOTES;


--2

CREATE INDEX QUOTES_TEXT_IDX
ON QUOTES(TEXT)
INDEXTYPE IS CTXSYS.CONTEXT;


--3

SELECT
    AUTHOR,
    TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, 'work', 1) > 0;

SELECT
    AUTHOR,
    TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, '$work', 1) > 0;

SELECT
    AUTHOR,
    TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, 'working', 1) > 0;

SELECT
    AUTHOR,
    TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, '$working', 1) > 0;


--4

SELECT
    AUTHOR,
    TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, 'it', 1) > 0;

-- Odp: Nie ma indeksu na slowo 'it'.

--5

SELECT * FROM CTX_STOPLISTS;

--Odp: Pewnie DEFAULT.

--6

SELECT * FROM CTX_STOPWORDS;


--7

DROP INDEX QUOTES_TEXT_IDX;

CREATE INDEX QUOTES_TEXT_IDX
ON QUOTES(TEXT)
INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS ('stoplist CTXSYS.EMPTY_STOPLIST');


--8

SELECT
    AUTHOR,
    TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, 'it', 1) > 0;

--Odp: Tak


--9

SELECT
    AUTHOR,
    TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, 'fool OR humans', 1) > 0;


--10

SELECT
    AUTHOR,
    TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, 'fool OR computer', 1) > 0;


--11

SELECT
    AUTHOR,
    TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, '(FOOL AND COMPUTER) WITHIN SENTENCE', 1) > 0;

--Odp: Podana sekcja SENTENCE nie istnieje w USER_SECTIONS.

--12

DROP INDEX QUOTES_TEXT_IDX;


--13

BEGIN
    ctx_ddl.create_section_group('nullgroup', 'NULL_SECTION_GROUP');
    ctx_ddl.add_special_section('nullgroup',  'SENTENCE');
    ctx_ddl.add_special_section('nullgroup',  'PARAGRAPH');
END;


--14

CREATE INDEX QUOTES_TEXT_IDX
ON QUOTES(TEXT)
INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS ('
    stoplist CTXSYS.EMPTY_STOPLIST
    section group nullgroup
');


--15

SELECT
    AUTHOR,
    TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, '(FOOL AND HUMANS) WITHIN SENTENCE', 1) > 0;

SELECT
    AUTHOR,
    TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, '(FOOL AND COMPUTER) WITHIN SENTENCE', 1) > 0;

--Odp: Dzialaja

--16

SELECT
    AUTHOR,
    TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, 'HUMANS', 1) > 0;


--17

DROP INDEX QUOTES_TEXT_IDX;

BEGIN
    ctx_ddl.create_preference('lex_z_m','BASIC_LEXER');
    ctx_ddl.set_attribute('lex_z_m', 'printjoins', '_-');
    ctx_ddl.set_attribute('lex_z_m', 'index_text', 'YES');
END;


CREATE INDEX QUOTES_TEXT_IDX
ON QUOTES(TEXT)
INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS ('
    stoplist CTXSYS.EMPTY_STOPLIST
    section group nullgroup
    LEXER lex_z_m
');


--18

SELECT
    AUTHOR,
    TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, 'HUMANS', 1) > 0;

--Odp: Nie zwrocil


--19

SELECT
    AUTHOR,
    TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, 'NON\-HUMANS', 1) > 0;


--20

DROP TABLE QUOTES;

BEGIN
    ctx_ddl.drop_preference('lex_z_m');
END;

