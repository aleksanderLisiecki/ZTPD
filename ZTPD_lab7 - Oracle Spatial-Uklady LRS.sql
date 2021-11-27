--1A

CREATE TABLE A6_LRS ( GEOM SDO_GEOMETRY );


--1B

SELECT * FROM STREETS_AND_RAILROADS;

INSERT INTO A6_LRS
SELECT
    S.GEOM
FROM STREETS_AND_RAILROADS S
WHERE S.ID = (
    select SR.ID
    from 
        STREETS_AND_RAILROADS SR,
        MAJOR_CITIES C
    where SDO_RELATE(SR.GEOM,
                    SDO_GEOM.SDO_BUFFER(C.GEOM, 10, 1, 'unit=km'),
                    'MASK=ANYINTERACT') = 'TRUE'
    and C.CITY_NAME = 'Koszalin'
);

SELECT * FROM A6_LRS;


--1C

select 
    SDO_GEOM.SDO_LENGTH(A.GEOM, 1, 'unit=km') DISTANCE,
    ST_LINESTRING(A.GEOM) .ST_NUMPOINTS() ST_NUMPOINTS
from A6_LRS A;

--1D

UPDATE A6_LRS A
SET GEOM = SDO_LRS.CONVERT_TO_LRS_GEOM(A.GEOM, 0, SDO_LRS.GEOM_SEGMENT_LENGTH(A.GEOM));


--1E

INSERT INTO USER_SDO_GEOM_METADATA VALUES (
    'A6_LRS',
    'GEOM',
    MDSYS.SDO_DIM_ARRAY(MDSYS.SDO_DIM_ELEMENT('X', 12.603676, 26.369824, 1),
    MDSYS.SDO_DIM_ELEMENT('Y', 45.8464, 58.0213, 1),
    MDSYS.SDO_DIM_ELEMENT('M', 0, 300, 1)),
    8307
);


--1F

CREATE INDEX A6_LRS_IDX
ON A6_LRS(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX;


--2A

SELECT SDO_LRS.VALID_MEASURE(GEOM, 500) VALID_500
FROM A6_LRS;


--2B

SELECT SDO_LRS.GEOM_SEGMENT_END_PT(GEOM) END_PT
FROM A6_LRS;


--2C

SELECT SDO_LRS.LOCATE_PT(A.GEOM, 150, 0) KM150
FROM A6_LRS A;


--2D

SELECT SDO_LRS.CLIP_GEOM_SEGMENT(A.GEOM, 120, 160)
FROM A6_LRS A;


--2E

SELECT SDO_LRS.GET_NEXT_SHAPE_PT(
    A.GEOM,
    SDO_LRS.PROJECT_PT(A.GEOM, C.GEOM)) WJAZD_NA_A6
FROM A6_LRS A,
    MAJOR_CITIES C
WHERE C.CITY_NAME = 'Slupsk';


--2F

SELECT
    SDO_GEOM.SDO_LENGTH(
        SDO_LRS.OFFSET_GEOM_SEGMENT(
            A.GEOM, M.DIMINFO, 50, 200, 50, 'unit=m'), 1, 'unit=m') KOSZT
FROM A6_LRS A, USER_SDO_GEOM_METADATA M
WHERE M.TABLE_NAME = 'A6_LRS'
    AND M.COLUMN_NAME = 'GEOM';