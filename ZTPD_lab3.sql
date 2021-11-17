--1

CREATE TABLE DOKUMENTY (
ID NUMBER(12) PRIMARY KEY,
DOKUMENT CLOB
);
    

--2

declare tmp CLOB;
begin
    FOR I in 1..1000
    LOOP
        tmp := CONCAT(tmp, 'Oto tekst ');
    END LOOP;

    INSERT INTO DOKUMENTY VALUES
    (1,tmp);
end;


--3

SELECT ID, UPPER(dokument) FROM DOKUMENTY

SELECT LENGTH(dokument) FROM DOKUMENTY

SELECT DBMS_LOB.GETLENGTH(dokument) FROM DOKUMENTY

SELECT SUBSTR(dokument,5,1000) FROM DOKUMENTY

SELECT DBMS_LOB.SUBSTR(dokument,5,1000) FROM DOKUMENTY


--4

INSERT INTO DOKUMENTY VALUES(2,EMPTY_CLOB())


--5

INSERT INTO DOKUMENTY VALUES (3,NULL)


--6

SELECT ID, UPPER(dokument) FROM DOKUMENTY

SELECT LENGTH(dokument) FROM DOKUMENTY

SELECT DBMS_LOB.GETLENGTH(dokument) FROM DOKUMENTY

SELECT SUBSTR(dokument,5,1000) FROM DOKUMENTY

SELECT DBMS_LOB.SUBSTR(dokument,5,1000) FROM DOKUMENTY


--7

select * from ALL_DIRECTORIES;


--8

DECLARE
    lobd clob;
    fils BFILE := BFILENAME('ZSBD_DIR','dokument.txt');
    doffset integer := 1;
    soffset integer := 1;
    langctx integer := 0;
    warn integer := null;
BEGIN
    select dokument into lobd from dokumenty
    where id=2
    FOR UPDATE;

    DBMS_LOB.fileopen(fils, DBMS_LOB.file_readonly);
    DBMS_LOB.LOADCLOBFROMFILE(lobd, fils, DBMS_LOB.LOBMAXSIZE, doffset, soffset, 873, langctx, warn);
    DBMS_LOB.FILECLOSE(fils);
    COMMIT;
END;


--9

update dokumenty
set dokument = TO_CLOB(BFILENAME('ZSBD_DIR','dokument.txt'))
where id = 3


--10

SELECT * FROM DOKUMENTY


--11

SELECT DBMS_LOB.GETLENGTH(dokument) FROM DOKUMENTY


--12

drop table dokumenty


--13

CREATE OR REPLACE PROCEDURE CLOB_CENSOR(
    lobd IN OUT CLOB,
    pattern VARCHAR2
)
IS
    position INTEGER;
    nth INTEGER := 1;
    replace_with VARCHAR2(100);
    counter INTEGER;
BEGIN
    FOR counter IN 1..length(pattern) LOOP
        replace_with := replace_with || '.';
    END LOOP;

    LOOP
        position := dbms_lob.instr(lobd, pattern, 1, nth);
        EXIT WHEN position = 0;
        dbms_lob.write(lobd, LENGTH(pattern), position, replace_with);
    END LOOP;
END CLOB_CENSOR;


--14

CREATE TABLE BIOGRAPHIES AS SELECT * FROM ZSBD_TOOLS.BIOGRAPHIES;

DECLARE
    lobd CLOB;
BEGIN
    SELECT bio INTO lobd FROM biographies WHERE id=1 FOR UPDATE;    
    CLOB_CENSOR(lobd, 'Cimrman');
    COMMIT;
END;


--15

DROP TABLE biographies;