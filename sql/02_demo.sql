-- 1. A valid Polygon is converted to MultiPolygon.
INSERT INTO demo.areas (name, geom)
VALUES (
    'valid polygon',
    ST_GeomFromText(
        'POLYGON((0 0, 0 100, 100 100, 100 0, 0 0))',
        3857
    )
);

-- 2. A self-intersecting polygon is repaired with ST_MakeValid.
INSERT INTO demo.areas (name, geom)
VALUES (
    'self-intersecting polygon',
    ST_GeomFromText(
        'POLYGON((0 0, 100 100, 100 0, 0 100, 0 0))',
        3857
    )
);

-- Inspect the normalized rows.
SELECT
    id,
    name,
    ST_GeometryType(geom) AS geometry_type,
    ST_SRID(geom) AS srid,
    ST_IsValid(geom) AS is_valid
FROM demo.areas
ORDER BY id;

-- 3. Uncomment to demonstrate rejection of an unexpected SRID.
-- INSERT INTO demo.areas (name, geom)
-- VALUES (
--     'wrong SRID',
--     ST_GeomFromText(
--         'POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))',
--         4326
--     )
-- );
