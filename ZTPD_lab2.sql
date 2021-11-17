--1

create table MOVIES (
ID NUMBER(12) PRIMARY KEY,
TITLE VARCHAR2(400) NOT NULL,
CATEGORY VARCHAR2(50),
YEAR CHAR(4),
CAST VARCHAR2(4000),
DIRECTOR VARCHAR2(4000),
STORY VARCHAR2(4000),
PRICE NUMBER(5,2),
COVER BLOB,
MIME_TYPE VARCHAR2(50)
);


--2

INSERT INTO MOVIES 
SELECT 
    d.ID, 
    d.TITLE, 
    d.category, 
    TRIM(d.year) AS YEAR, 
    d.cast, 
    d.director, 
    d.story, 
    d.price,
    c.IMAGE,
    c.MIME_TYPE
FROM DESCRIPTIONS d FULL OUTER JOIN COVERS c ON d.ID = c.MOVIE_ID;


--3

SELECT ID, title 
FROM movies 
WHERE COVER IS NULL;


--4

SELECT ID, title, LENGTH(cover) 
FROM movies 
WHERE COVER IS NOT NULL;


--5

SELECT ID, title, LENGTH(cover) 
FROM movies 
WHERE COVER IS  NULL;


--6

SELECT * FROM ALL_DIRECTORIES;


--7

UPDATE MOVIES
SET COVER = EMPTY_BLOB(), MIME_TYPE = 'image/jpeg'
WHERE ID = 66;


--8

SELECT ID, title, LENGTH(cover) 
FROM movies 
WHERE ID IN (65,66);


--9

DECLARE
lobd blob;
fils BFILE := BFILENAME('ZSBD_DIR','escape.jpg');
BEGIN
SELECT cover into lobd from movies
where id=66
FOR UPDATE;
DBMS_LOB.fileopen(fils, DBMS_LOB.file_readonly);
DBMS_LOB.LOADFROMFILE(lobd,fils,DBMS_LOB.GETLENGTH(fils));
DBMS_LOB.FILECLOSE(fils);
COMMIT;
END;


--10

CREATE TABLE TEMP_COVERS
(
    movie_id NUMBER(12),
    image BFILE,
    mime_type VARCHAR2(50)
);


--11

INSERT INTO temp_covers 
VALUES (65,BFILENAME('ZSBD_DIR','eagles.jpg'),'image/jpeg');

commit;


--12

select movie_id, DBMS_LOB.GETLENGTH(image) from temp_covers


--13

DECLARE
    v_mime_type VARCHAR2(50);
    v_image BFILE;
    a blob;
BEGIN
    SELECT mime_type into v_mime_type from temp_covers;
    SELECT image into v_image from temp_covers;
    DBMS_LOB.createtemporary(a, TRUE);
    DBMS_LOB.fileopen(v_image, DBMS_LOB.file_readonly);
    DBMS_LOB.LOADFROMFILE(a,v_image,DBMS_LOB.GETLENGTH(v_image));
    DBMS_LOB.FILECLOSE(v_image);
    update movies
    set cover = a, mime_type = v_mime_type
    where id = 65;
    dbms_lob.freetemporary(a);
    COMMIT;
END;


--14

select ID, title, length(cover) from movies where ID in (65,66);


--15

drop table MOVIES;
drop table TEMP_COVERS;
