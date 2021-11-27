--1A

INSERT INTO USER_SDO_GEOM_METADATA 
VALUES (
'FIGURY',
'KSZTALT',
MDSYS.SDO_DIM_ARRAY(
    MDSYS.SDO_DIM_ELEMENT('X', 0, 100, 0.01),
    MDSYS.SDO_DIM_ELEMENT('Y', 0, 100, 0.01)
),
NULL
);

SELECT * FROM USER_SDO_GEOM_METADATA;


--1B

SELECT SDO_TUNE.ESTIMATE_RTREE_INDEX_SIZE(3000000, 8192, 10, 2, 0)
FROM FIGURY
WHERE ROWNUM <= 1;


--1C

CREATE INDEX ksztalt_spatial_idx
ON FIGURY(KSZTALT)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;


--1D

select ID
from FIGURY
where SDO_FILTER(KSZTALT,
    SDO_GEOMETRY(2001,null,
        SDO_POINT_TYPE(3,3,null),
        null,null)
) = 'TRUE';
    
-- Odpowiedz:
-- Operator SDO_FILTER, ktory wykorzystuje tylko filtr podstawowy
-- uznal, ze wszystkie 3 elementy "maja cos wspolnego". 


--1E

SELECT ID
FROM FIGURY
WHERE SDO_RELATE(KSZTALT,
    SDO_GEOMETRY(2001,null,
        SDO_POINT_TYPE(3,3,null),
        null,null),
    'mask=ANYINTERACT'
    ) = 'TRUE';
    
-- Odpowiedz:
-- Operator SDO_RELATE dokonuje dodatkowej weryfikacji zbioru kandydatow 
-- wykorzystujac obie fazy przetwarzania. Uznal on, ze tylko figura 2 "ma co� wspolnego".


--2A

SELECT
    A.CITY_NAME MIASTO,
    ROUND(SDO_NN_DISTANCE(1), 7) ODL
FROM 
    MAJOR_CITIES A,
    MAJOR_CITIES B
WHERE
    SDO_NN(
        A.GEOM,
        MDSYS.SDO_GEOMETRY(
            2001,
            8307,
            B.GEOM.SDO_POINT,
            B.GEOM.SDO_ELEM_INFO,
            B.GEOM.SDO_ORDINATES
        ),
        'sdo_num_res=10 unit=km',
        1
    ) = 'TRUE'
    AND B.CITY_NAME = 'Warsaw'
    AND A.CITY_NAME <> 'Warsaw';


--2B

SELECT
    A.CITY_NAME MIASTO
FROM 
    MAJOR_CITIES A,
    MAJOR_CITIES B
WHERE
    SDO_WITHIN_DISTANCE(
        A.GEOM,
        MDSYS.SDO_GEOMETRY(
            2001,
            8307,
            B.GEOM.SDO_POINT,
            B.GEOM.SDO_ELEM_INFO,
            B.GEOM.SDO_ORDINATES
        ),
        'distance=100 unit=km'
    ) = 'TRUE'
    AND B.CITY_NAME = 'Warsaw'
    AND A.CITY_NAME <> 'Warsaw';


--2C

SELECT
    B.CNTRY_NAME KRAJ,
    C.CITY_NAME MIASTO
FROM 
    COUNTRY_BOUNDARIES B,
    MAJOR_CITIES C
WHERE
    SDO_RELATE(C.GEOM, B.GEOM, 'mask=INSIDE') = 'TRUE'
    AND B.CNTRY_NAME = 'Slovakia';


--2D

SELECT
    A.CNTRY_NAME PANSTWO,
    ROUND(SDO_GEOM.SDO_DISTANCE(A.GEOM, B.GEOM, 1, 'unit=km'), 7) ODL
FROM 
    COUNTRY_BOUNDARIES A,
    COUNTRY_BOUNDARIES B
WHERE
    SDO_RELATE(
        A.GEOM,
        SDO_GEOMETRY(
            2001,
            8307,
            B.GEOM.SDO_POINT,
            B.GEOM.SDO_ELEM_INFO,
            B.GEOM.SDO_ORDINATES 
        ),
        'mask=ANYINTERACT'
    ) != 'TRUE'
    AND B.CNTRY_NAME = 'Poland';


--3A

SELECT
    A.CNTRY_NAME,
    ROUND(SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(A.GEOM, B.GEOM, 1), 1, 'unit=km'), 8) ODLEGLOSC
FROM 
    COUNTRY_BOUNDARIES A,
    COUNTRY_BOUNDARIES B
WHERE
    SDO_FILTER(A.GEOM, B.GEOM) = 'TRUE'
    AND B.CNTRY_NAME = 'Poland';


--3B

SELECT 
    CNTRY_NAME
FROM 
    COUNTRY_BOUNDARIES
WHERE 
    SDO_GEOM.SDO_AREA(GEOM) = (
    SELECT 
        MAX(SDO_GEOM.SDO_AREA(GEOM)) 
    FROM 
        COUNTRY_BOUNDARIES);


--3C

SELECT
    ROUND(
        SDO_GEOM.SDO_AREA(
            SDO_GEOM.SDO_MBR(
                SDO_GEOM.SDO_UNION(
                    A.GEOM,
                    B.GEOM,
                    0.01
                )
            ),
            1,
            'unit=SQ_KM'
        ),
        5
    ) SQ_KM
FROM 
    MAJOR_CITIES A,
    MAJOR_CITIES B
WHERE 
    A.CITY_NAME = 'Warsaw'
    AND B.CITY_NAME = 'Lodz';


--3D

SELECT
    SDO_GEOM.SDO_UNION(A.GEOM, B.GEOM, 0.01).GET_DIMS() ||
    SDO_GEOM.SDO_UNION(A.GEOM, B.GEOM, 0.01).GET_LRS_DIM() ||
    LPAD(SDO_GEOM.SDO_UNION(A.GEOM, B.GEOM, 0.01).GET_GTYPE(), 2, '0') GTYPE
FROM 
    COUNTRY_BOUNDARIES A,
    MAJOR_CITIES B
WHERE 
    A.CNTRY_NAME = 'Poland'
    AND B.CITY_NAME = 'Prague';


--3E

SELECT
    B.CITY_NAME,
    A.CNTRY_NAME
FROM 
    COUNTRY_BOUNDARIES A,
    MAJOR_CITIES B
WHERE
    A.CNTRY_NAME = B.CNTRY_NAME
    AND SDO_GEOM.SDO_DISTANCE(
        SDO_GEOM.SDO_CENTROID(A.GEOM, 1),
        B.GEOM,
        1) = (
            SELECT MIN(SDO_GEOM.SDO_DISTANCE(SDO_GEOM.SDO_CENTROID(A.GEOM, 1), B.GEOM, 1))
            FROM COUNTRY_BOUNDARIES A, MAJOR_CITIES B
            WHERE A.CNTRY_NAME = B.CNTRY_NAME
        );


--3F

SELECT
    NAME,
    ROUND(SUM(DLUGOSC), 7) DLUGOSC
FROM (
    SELECT
        B.NAME,
        SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(A.GEOM, B.GEOM, 1), 1, 'unit=KM') DLUGOSC
    FROM 
        COUNTRY_BOUNDARIES A,
        RIVERS B
    WHERE
        SDO_RELATE(
            A.GEOM,
            SDO_GEOMETRY(
                2001,
                8307,
                B.GEOM.SDO_POINT,
                B.GEOM.SDO_ELEM_INFO,
                B.GEOM.SDO_ORDINATES
            ),
            'mask=ANYINTERACT'
        ) = 'TRUE'
        AND A.CNTRY_NAME = 'Poland')
GROUP BY NAME;
