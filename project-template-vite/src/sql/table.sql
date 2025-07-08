-- todo: 替換 OWNER

-- Table: public.member

-- DROP TABLE public.member;

CREATE TABLE public.member
(
    id integer NOT NULL DEFAULT nextval('member_id_seq'::regclass),
    account character varying(50) COLLATE pg_catalog."default" NOT NULL,
    whisper character varying(50) COLLATE pg_catalog."default" NOT NULL,
    name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    status integer NOT NULL,
    created_user character varying(50) COLLATE pg_catalog."default" NOT NULL,
    created_date timestamp without time zone NOT NULL,
    modified_user character varying(50) COLLATE pg_catalog."default" NOT NULL,
    modified_date timestamp without time zone NOT NULL,
    CONSTRAINT member_pkey PRIMARY KEY (id),
    CONSTRAINT member_account_key UNIQUE (account)

)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.member
    OWNER to temp_own;

GRANT ALL ON TABLE public.member TO temp_own;



GRANT ALL ON TABLE public.member TO temp_write;

COMMENT ON TABLE public.member
    IS '使用者';

COMMENT ON COLUMN public.member.id
    IS '系統序號';

COMMENT ON COLUMN public.member.account
    IS '帳號';

COMMENT ON COLUMN public.member.whisper
    IS '密碼';

COMMENT ON COLUMN public.member.name
    IS '使用者名稱';

COMMENT ON COLUMN public.member.status
    IS '狀態:0=未啟用,1=啟用,-1=停用';

COMMENT ON COLUMN public.member.created_user
    IS '建立者';

COMMENT ON COLUMN public.member.created_date
    IS '建立時間';

COMMENT ON COLUMN public.member.modified_user
    IS '修改者';

COMMENT ON COLUMN public.member.modified_date
    IS '修改時間';

-- Table: public.permission

-- DROP TABLE public.permission;

CREATE TABLE public.permission
(
    id integer NOT NULL DEFAULT nextval('permission_id_seq'::regclass),
    name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    created_user character varying(100) COLLATE pg_catalog."default" NOT NULL,
    created_date timestamp without time zone NOT NULL,
    modified_user character varying(100) COLLATE pg_catalog."default" NOT NULL,
    modified_date timestamp without time zone NOT NULL,
    CONSTRAINT permission_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.permission
    OWNER to temp_own;



GRANT ALL ON TABLE public.permission TO temp_write;

GRANT ALL ON TABLE public.permission TO temp_own;

COMMENT ON TABLE public.permission
    IS '權限';

COMMENT ON COLUMN public.permission.id
    IS '系統序號';

COMMENT ON COLUMN public.permission.name
    IS '權限名稱';

COMMENT ON COLUMN public.permission.created_user
    IS '建立者';

COMMENT ON COLUMN public.permission.created_date
    IS '建立時間';

COMMENT ON COLUMN public.permission.modified_user
    IS '修改者';

COMMENT ON COLUMN public.permission.modified_date
    IS '修改時間';

-- Table: public.permission_group

-- DROP TABLE public.permission_group;

CREATE TABLE public.permission_group
(
    id integer NOT NULL DEFAULT nextval('permission_group_id_seq'::regclass),
    member_id integer NOT NULL,
    permission_id integer NOT NULL,
    created_user character varying(100) COLLATE pg_catalog."default" NOT NULL,
    created_date timestamp without time zone NOT NULL,
    CONSTRAINT permission_group_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.permission_group
    OWNER to temp_own;



GRANT ALL ON TABLE public.permission_group TO temp_write;

GRANT ALL ON TABLE public.permission_group TO temp_own;

COMMENT ON TABLE public.permission_group
    IS '權限使用者關聯';

COMMENT ON COLUMN public.permission_group.id
    IS '系統序號';

COMMENT ON COLUMN public.permission_group.member_id
    IS '使用者序號';

COMMENT ON COLUMN public.permission_group.permission_id
    IS '權限序號';

COMMENT ON COLUMN public.permission_group.created_user
    IS '建立者';

COMMENT ON COLUMN public.permission_group.created_date
    IS '建立時間';

-- Table: public.permission_item

-- DROP TABLE public.permission_item;

CREATE TABLE public.permission_item
(
    id integer NOT NULL DEFAULT nextval('permission_item_id_seq'::regclass),
    permission_id integer NOT NULL,
    name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    type integer NOT NULL,
    created_user character varying(100) COLLATE pg_catalog."default" NOT NULL,
    created_date timestamp without time zone NOT NULL,
    CONSTRAINT permission_item_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.permission_item
    OWNER to temp_own;



GRANT ALL ON TABLE public.permission_item TO temp_write;

GRANT ALL ON TABLE public.permission_item TO temp_own;

COMMENT ON TABLE public.permission_item
    IS '權限項目';

COMMENT ON COLUMN public.permission_item.id
    IS '系統序號';

COMMENT ON COLUMN public.permission_item.permission_id
    IS '權限序號';

COMMENT ON COLUMN public.permission_item.name
    IS '權限項目名稱';

COMMENT ON COLUMN public.permission_item.type
    IS '權限類型:0=頁面,1=功能';

COMMENT ON COLUMN public.permission_item.created_user
    IS '建立者';

COMMENT ON COLUMN public.permission_item.created_date
    IS '建立時間';