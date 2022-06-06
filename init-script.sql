--
-- PostgreSQL database dump
--

-- Dumped from database version 12.7
-- Dumped by pg_dump version 12.10

-- Started on 2022-06-03 12:03:47 UTC

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE cemit;
--
-- TOC entry 4943 (class 1262 OID 16384)
-- Name: cemit; Type: DATABASE; Schema: -; Owner: cemit
--

CREATE DATABASE cemit WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';


ALTER DATABASE cemit OWNER TO cemit;

\connect cemit

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 17478)
-- Name: timescaledb; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS timescaledb WITH SCHEMA public;


--
-- TOC entry 4944 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION timescaledb; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION timescaledb IS 'Enables scalable inserts and complex queries for time-series data';


--
-- TOC entry 3 (class 3079 OID 18040)
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- TOC entry 4945 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- TOC entry 1678 (class 1255 OID 20469)
-- Name: ge_id(integer); Type: FUNCTION; Schema: public; Owner: cemit
--

CREATE FUNCTION public.ge_id(id integer) RETURNS TABLE(learn_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        lat, lon
    FROM
        public.b_box_weights
    WHERE
        b_box_id = id ;
END ; $$;


ALTER FUNCTION public.ge_id(id integer) OWNER TO cemit;

--
-- TOC entry 1680 (class 1255 OID 20792)
-- Name: get_b_boxes(); Type: FUNCTION; Schema: public; Owner: cemit
--

CREATE FUNCTION public.get_b_boxes() RETURNS TABLE(id integer, track_name text, min_lat double precision, max_lat double precision, min_lon double precision, max_lon double precision, weight integer, coordinates text)
    LANGUAGE plpgsql STRICT
    AS $$
DECLARE 
		target record;
		b_boxes record;
		b_box_weight record;
		coordinates TEXT;
		cord record;
		res record;
		weight INT;

		BEGIN
		DROP TABLE  IF EXISTS final_res ;
		CREATE TEMP TABLE IF NOT EXISTS final_res (
		id INT,
		track_name TEXT,
		max_lat DOUBLE PRECISION,
		min_lat DOUBLE PRECISION,
		max_lon DOUBLE PRECISION,
		min_lon DOUBLE PRECISION,
		weight INT,
		coordinates TEXT
	 );
		FOR target IN SELECT DISTINCT(b_box_id) FROM PUBLIC.b_box_coordinates WHERE lon BETWEEN 5.256971 AND 5.259981 AND lat BETWEEN 60.287904 AND 60.288585
		LOOP
			coordinates:= '';
			SELECT * from PUBLIC.b_boxes where PUBLIC.b_boxes.id = target.b_box_id into b_boxes;
			SELECT b_box_id, PUBLIC.b_box_weights.weight from PUBLIC.b_box_weights where PUBLIC.b_box_weights.b_box_id = target.b_box_id AND PUBLIC.b_box_weights.week =  22 AND PUBLIC.b_box_weights.year = 2022 into b_box_weight;
			IF b_box_weight.weight IS NULL THEN
				weight:= 0;
			ELSIF b_box_weight.weight IS NOT NULL THEN
				weight:= b_box_weight.weight;
			END IF;
			FOR cord IN SELECT lat, lon from PUBLIC.b_box_coordinates where b_box_id = target.b_box_id 
			LOOP
				coordinates:= CONCAT(coordinates, ',', cord);
			END LOOP;

			INSERT INTO final_res (id, track_name, max_lon, min_lon, max_lat, min_lat, weight, coordinates) 
			VALUES (b_boxes.id, b_boxes.track_name, b_boxes.max_lon, b_boxes.min_lon, b_boxes.max_lat, b_boxes.min_lat, weight, coordinates);
			

		END LOOP;

		RETURN QUERY
		select * from final_res;
		


END
$$;


ALTER FUNCTION public.get_b_boxes() OWNER TO cemit;

--
-- TOC entry 1679 (class 1255 OID 20601)
-- Name: my_function(); Type: FUNCTION; Schema: public; Owner: cemit
--

CREATE FUNCTION public.my_function() RETURNS TABLE(sname text, pname text)
    LANGUAGE plpgsql
    AS $$
DECLARE
  running_schema text;
  running_name text;
  DYN_SQL constant text default 'select "name" from %I.person';
BEGIN
  for running_schema in --your query 
   SELECT schema_name FROM information_schema.schemata WHERE schema_name LIKE 'myschema_%'
  loop
    for running_name in execute format(DYN_SQL, running_schema) loop
       sname := running_schema;
       pname := running_name;
       return next;
    end loop;
  end loop;
END;
$$;


ALTER FUNCTION public.my_function() OWNER TO cemit;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 275 (class 1259 OID 20310)
-- Name: b_box_coordinates; Type: TABLE; Schema: public; Owner: cemit
--

CREATE TABLE public.b_box_coordinates (
    id integer NOT NULL,
    b_box_id integer,
    lat double precision,
    lon double precision,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE public.b_box_coordinates OWNER TO cemit;

--
-- TOC entry 274 (class 1259 OID 20308)
-- Name: b_box_coordinates_id_seq; Type: SEQUENCE; Schema: public; Owner: cemit
--

CREATE SEQUENCE public.b_box_coordinates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.b_box_coordinates_id_seq OWNER TO cemit;

--
-- TOC entry 4946 (class 0 OID 0)
-- Dependencies: 274
-- Name: b_box_coordinates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cemit
--

ALTER SEQUENCE public.b_box_coordinates_id_seq OWNED BY public.b_box_coordinates.id;


--
-- TOC entry 277 (class 1259 OID 20326)
-- Name: b_box_weights; Type: TABLE; Schema: public; Owner: cemit
--

CREATE TABLE public.b_box_weights (
    id integer NOT NULL,
    b_box_id integer,
    week integer NOT NULL,
    year integer NOT NULL,
    weight integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone
);


ALTER TABLE public.b_box_weights OWNER TO cemit;

--
-- TOC entry 276 (class 1259 OID 20324)
-- Name: b_box_weights_id_seq; Type: SEQUENCE; Schema: public; Owner: cemit
--

CREATE SEQUENCE public.b_box_weights_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.b_box_weights_id_seq OWNER TO cemit;

--
-- TOC entry 4947 (class 0 OID 0)
-- Dependencies: 276
-- Name: b_box_weights_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cemit
--

ALTER SEQUENCE public.b_box_weights_id_seq OWNED BY public.b_box_weights.id;


--
-- TOC entry 273 (class 1259 OID 20302)
-- Name: b_boxes; Type: TABLE; Schema: public; Owner: cemit
--

CREATE TABLE public.b_boxes (
    id integer NOT NULL,
    track_name character varying(255) NOT NULL,
    max_lat double precision,
    min_lat double precision,
    max_lon double precision,
    min_lon double precision,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE public.b_boxes OWNER TO cemit;

--
-- TOC entry 272 (class 1259 OID 20300)
-- Name: b_boxes_id_seq; Type: SEQUENCE; Schema: public; Owner: cemit
--

CREATE SEQUENCE public.b_boxes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.b_boxes_id_seq OWNER TO cemit;

--
-- TOC entry 4948 (class 0 OID 0)
-- Dependencies: 272
-- Name: b_boxes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cemit
--

ALTER SEQUENCE public.b_boxes_id_seq OWNED BY public.b_boxes.id;


--
-- TOC entry 271 (class 1259 OID 19650)
-- Name: imupoints; Type: TABLE; Schema: public; Owner: cemit
--

CREATE TABLE public.imupoints (
    device_id character varying NOT NULL,
    "time" timestamp with time zone NOT NULL,
    lat double precision,
    lon double precision,
    geom public.geometry(Point,4326),
    kmh double precision,
    acc_x_min double precision,
    acc_x_max double precision,
    acc_x_abs_max double precision,
    acc_x_mean double precision,
    acc_x_rms double precision,
    acc_x_stddev double precision,
    acc_y_min double precision,
    acc_y_max double precision,
    acc_y_abs_max double precision,
    acc_y_mean double precision,
    acc_y_rms double precision,
    acc_y_stddev double precision,
    acc_z_min double precision,
    acc_z_max double precision,
    acc_z_abs_max double precision,
    acc_z_mean double precision,
    acc_z_rms double precision,
    acc_z_stddev double precision,
    ang_pitch double precision,
    ang_pitch_abs double precision,
    ang_roll double precision,
    ang_roll_abs double precision
);


ALTER TABLE public.imupoints OWNER TO cemit;

--
-- TOC entry 4709 (class 2604 OID 20313)
-- Name: b_box_coordinates id; Type: DEFAULT; Schema: public; Owner: cemit
--

ALTER TABLE ONLY public.b_box_coordinates ALTER COLUMN id SET DEFAULT nextval('public.b_box_coordinates_id_seq'::regclass);


--
-- TOC entry 4710 (class 2604 OID 20329)
-- Name: b_box_weights id; Type: DEFAULT; Schema: public; Owner: cemit
--

ALTER TABLE ONLY public.b_box_weights ALTER COLUMN id SET DEFAULT nextval('public.b_box_weights_id_seq'::regclass);


--
-- TOC entry 4708 (class 2604 OID 20305)
-- Name: b_boxes id; Type: DEFAULT; Schema: public; Owner: cemit
--

ALTER TABLE ONLY public.b_boxes ALTER COLUMN id SET DEFAULT nextval('public.b_boxes_id_seq'::regclass);


--
-- TOC entry 4789 (class 2606 OID 20315)
-- Name: b_box_coordinates b_box_coordinates_pkey; Type: CONSTRAINT; Schema: public; Owner: cemit
--

ALTER TABLE ONLY public.b_box_coordinates
    ADD CONSTRAINT b_box_coordinates_pkey PRIMARY KEY (id);


--
-- TOC entry 4792 (class 2606 OID 20331)
-- Name: b_box_weights b_box_weights_pkey; Type: CONSTRAINT; Schema: public; Owner: cemit
--

ALTER TABLE ONLY public.b_box_weights
    ADD CONSTRAINT b_box_weights_pkey PRIMARY KEY (id);


--
-- TOC entry 4787 (class 2606 OID 20307)
-- Name: b_boxes b_boxes_pkey; Type: CONSTRAINT; Schema: public; Owner: cemit
--

ALTER TABLE ONLY public.b_boxes
    ADD CONSTRAINT b_boxes_pkey PRIMARY KEY (id);


--
-- TOC entry 4785 (class 2606 OID 19657)
-- Name: imupoints imupoints_pkey; Type: CONSTRAINT; Schema: public; Owner: cemit
--

ALTER TABLE ONLY public.imupoints
    ADD CONSTRAINT imupoints_pkey PRIMARY KEY (device_id, "time");


--
-- TOC entry 4790 (class 1259 OID 20468)
-- Name: b_box_weights_b_box_id_week_year_idx; Type: INDEX; Schema: public; Owner: cemit
--

CREATE UNIQUE INDEX b_box_weights_b_box_id_week_year_idx ON public.b_box_weights USING btree (b_box_id, week, year);


--
-- TOC entry 4793 (class 2606 OID 20316)
-- Name: b_box_coordinates b_box_coordinates_b_box_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cemit
--

ALTER TABLE ONLY public.b_box_coordinates
    ADD CONSTRAINT b_box_coordinates_b_box_id_fkey FOREIGN KEY (b_box_id) REFERENCES public.b_boxes(id);


--
-- TOC entry 4794 (class 2606 OID 20332)
-- Name: b_box_weights b_box_weights_b_box_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cemit
--

ALTER TABLE ONLY public.b_box_weights
    ADD CONSTRAINT b_box_weights_b_box_id_fkey FOREIGN KEY (b_box_id) REFERENCES public.b_boxes(id);


-- Completed on 2022-06-03 12:03:48 UTC

--
-- PostgreSQL database dump complete
--

