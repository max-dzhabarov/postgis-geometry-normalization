CREATE EXTENSION IF NOT EXISTS postgis;

CREATE SCHEMA IF NOT EXISTS demo;

DROP TABLE IF EXISTS demo.areas CASCADE;

CREATE TABLE demo.areas (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL,
    geom geometry(MultiPolygon, 3857)
);

CREATE OR REPLACE FUNCTION demo.normalize_multipolygon_before_save()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    expected_srid integer := TG_ARGV[0]::integer;
BEGIN
    IF NEW.geom IS NULL THEN
        RETURN NEW;
    END IF;

    NEW.geom := ST_Force2D(NEW.geom);

    IF ST_SRID(NEW.geom) = 0 THEN
        NEW.geom := ST_SetSRID(NEW.geom, expected_srid);
    ELSIF ST_SRID(NEW.geom) <> expected_srid THEN
        RAISE EXCEPTION
            'Unexpected SRID: %, expected %',
            ST_SRID(NEW.geom),
            expected_srid;
    END IF;

    IF NOT ST_IsValid(NEW.geom) THEN
        NEW.geom := ST_MakeValid(NEW.geom);
    END IF;

    NEW.geom := ST_Multi(ST_CollectionExtract(NEW.geom, 3));

    IF ST_IsEmpty(NEW.geom) THEN
        RAISE EXCEPTION 'Geometry contains no polygonal components';
    END IF;

    IF NOT ST_IsValid(NEW.geom) THEN
        RAISE EXCEPTION
            'Geometry remains invalid after normalization: %',
            ST_IsValidReason(NEW.geom);
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_normalize_multipolygon
BEFORE INSERT OR UPDATE OF geom
ON demo.areas
FOR EACH ROW
EXECUTE FUNCTION demo.normalize_multipolygon_before_save('3857');
