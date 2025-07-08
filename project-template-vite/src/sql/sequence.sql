-- todo: 替換 OWNER

-- SEQUENCE: public.member_id_seq

-- DROP SEQUENCE public.member_id_seq;

CREATE SEQUENCE public.member_id_seq;

ALTER SEQUENCE public.member_id_seq
    OWNER TO temp_own;

GRANT ALL ON SEQUENCE public.member_id_seq TO temp_own;



GRANT ALL ON SEQUENCE public.member_id_seq TO temp_write;

-- SEQUENCE: public.permission_id_seq

-- DROP SEQUENCE public.permission_id_seq;

CREATE SEQUENCE public.permission_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

ALTER SEQUENCE public.permission_id_seq
    OWNER TO temp_own;



GRANT ALL ON SEQUENCE public.permission_id_seq TO temp_write;

GRANT ALL ON SEQUENCE public.permission_id_seq TO temp_own;

-- SEQUENCE: public.permission_group_id_seq

-- DROP SEQUENCE public.permission_group_id_seq;

CREATE SEQUENCE public.permission_group_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

ALTER SEQUENCE public.permission_group_id_seq
    OWNER TO temp_own;



GRANT ALL ON SEQUENCE public.permission_group_id_seq TO temp_write;

GRANT ALL ON SEQUENCE public.permission_group_id_seq TO temp_own;


-- SEQUENCE: public.permission_item_id_seq

-- DROP SEQUENCE public.permission_item_id_seq;

CREATE SEQUENCE public.permission_item_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

ALTER SEQUENCE public.permission_item_id_seq
    OWNER TO temp_own;



GRANT ALL ON SEQUENCE public.permission_item_id_seq TO temp_write;

GRANT ALL ON SEQUENCE public.permission_item_id_seq TO temp_own;