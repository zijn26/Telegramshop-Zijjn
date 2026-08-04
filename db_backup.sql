--
-- PostgreSQL database dump
--

\restrict K04ZNgnKPUJ8YOVO76TeM47Xe6GYV4OlpokDdDjNwcuqVbpWVqjX56chczIfcx9

-- Dumped from database version 16.14
-- Dumped by pg_dump version 16.14

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

ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_role_id_fkey;
ALTER TABLE IF EXISTS ONLY public.stock_subscriptions DROP CONSTRAINT IF EXISTS stock_subscriptions_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.stock_subscriptions DROP CONSTRAINT IF EXISTS stock_subscriptions_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reviews DROP CONSTRAINT IF EXISTS reviews_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reviews DROP CONSTRAINT IF EXISTS reviews_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.referral_earnings DROP CONSTRAINT IF EXISTS referral_earnings_referrer_id_fkey;
ALTER TABLE IF EXISTS ONLY public.referral_earnings DROP CONSTRAINT IF EXISTS referral_earnings_referral_id_fkey;
ALTER TABLE IF EXISTS ONLY public.promo_codes DROP CONSTRAINT IF EXISTS promo_codes_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.promo_codes DROP CONSTRAINT IF EXISTS promo_codes_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.promo_code_usages DROP CONSTRAINT IF EXISTS promo_code_usages_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.promo_code_usages DROP CONSTRAINT IF EXISTS promo_code_usages_promo_id_fkey;
ALTER TABLE IF EXISTS ONLY public.payments DROP CONSTRAINT IF EXISTS payments_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.operations DROP CONSTRAINT IF EXISTS operations_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.item_values DROP CONSTRAINT IF EXISTS item_values_new_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.goods DROP CONSTRAINT IF EXISTS goods_new_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.gacha_user_wins DROP CONSTRAINT IF EXISTS gacha_user_wins_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.gacha_user_wins DROP CONSTRAINT IF EXISTS gacha_user_wins_gacha_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.gacha_items DROP CONSTRAINT IF EXISTS gacha_items_goods_id_fkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS fk_users_role_id_roles;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS fk_users_referral_id_users;
ALTER TABLE IF EXISTS ONLY public.content_pages DROP CONSTRAINT IF EXISTS content_pages_parent_id_fkey;
ALTER TABLE IF EXISTS ONLY public.cart_items DROP CONSTRAINT IF EXISTS cart_items_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.cart_items DROP CONSTRAINT IF EXISTS cart_items_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bought_goods DROP CONSTRAINT IF EXISTS bought_goods_buyer_id_fkey;
DROP INDEX IF EXISTS public.ix_users_role_id;
DROP INDEX IF EXISTS public.ix_users_registration_date;
DROP INDEX IF EXISTS public.ix_users_referral_id;
DROP INDEX IF EXISTS public.ix_users_is_blocked;
DROP INDEX IF EXISTS public.ix_stock_subscriptions_user_id;
DROP INDEX IF EXISTS public.ix_stock_subscriptions_item_id;
DROP INDEX IF EXISTS public.ix_roles_default;
DROP INDEX IF EXISTS public.ix_reviews_user_id;
DROP INDEX IF EXISTS public.ix_reviews_item_id;
DROP INDEX IF EXISTS public.ix_referral_earnings_referrer_id;
DROP INDEX IF EXISTS public.ix_referral_earnings_referrer_created;
DROP INDEX IF EXISTS public.ix_referral_earnings_referral_id;
DROP INDEX IF EXISTS public.ix_referral_earnings_referral_created;
DROP INDEX IF EXISTS public.ix_promo_codes_is_active;
DROP INDEX IF EXISTS public.ix_promo_codes_code;
DROP INDEX IF EXISTS public.ix_payments_user_id;
DROP INDEX IF EXISTS public.ix_payments_status_created;
DROP INDEX IF EXISTS public.ix_payments_provider;
DROP INDEX IF EXISTS public.ix_operations_user_id;
DROP INDEX IF EXISTS public.ix_operations_time;
DROP INDEX IF EXISTS public.ix_media_vault_uploader_user_id;
DROP INDEX IF EXISTS public.ix_media_vault_media_type;
DROP INDEX IF EXISTS public.ix_media_vault_file_id;
DROP INDEX IF EXISTS public.ix_item_values_new_item_inf;
DROP INDEX IF EXISTS public.ix_item_values_new_item_id;
DROP INDEX IF EXISTS public.ix_goods_new_category_id;
DROP INDEX IF EXISTS public.ix_goods_name_trgm;
DROP INDEX IF EXISTS public.ix_goods_description_trgm;
DROP INDEX IF EXISTS public.ix_content_pages_parent_id;
DROP INDEX IF EXISTS public.ix_content_pages_is_active;
DROP INDEX IF EXISTS public.ix_cart_items_user_id;
DROP INDEX IF EXISTS public.ix_cart_items_item_id;
DROP INDEX IF EXISTS public.ix_bought_goods_datetime;
DROP INDEX IF EXISTS public.ix_bought_goods_buyer_id;
DROP INDEX IF EXISTS public.ix_bought_goods_buyer_datetime;
DROP INDEX IF EXISTS public.ix_audit_log_user_id;
DROP INDEX IF EXISTS public.ix_audit_log_timestamp;
DROP INDEX IF EXISTS public.ix_audit_log_action;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.stock_subscriptions DROP CONSTRAINT IF EXISTS uq_stock_sub_per_user_item;
ALTER TABLE IF EXISTS ONLY public.reviews DROP CONSTRAINT IF EXISTS uq_review_per_user_item;
ALTER TABLE IF EXISTS ONLY public.promo_code_usages DROP CONSTRAINT IF EXISTS uq_promo_usage_per_user;
ALTER TABLE IF EXISTS ONLY public.payments DROP CONSTRAINT IF EXISTS uq_payment_provider_ext;
ALTER TABLE IF EXISTS ONLY public.item_values DROP CONSTRAINT IF EXISTS uq_item_value_per_item_new;
ALTER TABLE IF EXISTS ONLY public.cart_items DROP CONSTRAINT IF EXISTS uq_cart_item_per_user;
ALTER TABLE IF EXISTS ONLY public.storefront_settings DROP CONSTRAINT IF EXISTS storefront_settings_pkey;
ALTER TABLE IF EXISTS ONLY public.stock_subscriptions DROP CONSTRAINT IF EXISTS stock_subscriptions_pkey;
ALTER TABLE IF EXISTS ONLY public.roles DROP CONSTRAINT IF EXISTS roles_pkey;
ALTER TABLE IF EXISTS ONLY public.roles DROP CONSTRAINT IF EXISTS roles_name_key;
ALTER TABLE IF EXISTS ONLY public.reviews DROP CONSTRAINT IF EXISTS reviews_pkey;
ALTER TABLE IF EXISTS ONLY public.referral_earnings DROP CONSTRAINT IF EXISTS referral_earnings_pkey;
ALTER TABLE IF EXISTS ONLY public.promo_codes DROP CONSTRAINT IF EXISTS promo_codes_pkey;
ALTER TABLE IF EXISTS ONLY public.promo_code_usages DROP CONSTRAINT IF EXISTS promo_code_usages_pkey;
ALTER TABLE IF EXISTS ONLY public.payments DROP CONSTRAINT IF EXISTS payments_pkey;
ALTER TABLE IF EXISTS ONLY public.operations DROP CONSTRAINT IF EXISTS operations_pkey;
ALTER TABLE IF EXISTS ONLY public.media_vault DROP CONSTRAINT IF EXISTS media_vault_pkey;
ALTER TABLE IF EXISTS ONLY public.media_capture_settings DROP CONSTRAINT IF EXISTS media_capture_settings_pkey;
ALTER TABLE IF EXISTS ONLY public.item_values DROP CONSTRAINT IF EXISTS item_values_new_pkey;
ALTER TABLE IF EXISTS ONLY public.goods DROP CONSTRAINT IF EXISTS goods_new_pkey;
ALTER TABLE IF EXISTS ONLY public.goods DROP CONSTRAINT IF EXISTS goods_new_name_key;
ALTER TABLE IF EXISTS ONLY public.gacha_user_wins DROP CONSTRAINT IF EXISTS gacha_user_wins_pkey;
ALTER TABLE IF EXISTS ONLY public.gacha_settings DROP CONSTRAINT IF EXISTS gacha_settings_pkey;
ALTER TABLE IF EXISTS ONLY public.gacha_items DROP CONSTRAINT IF EXISTS gacha_items_pkey;
ALTER TABLE IF EXISTS ONLY public.content_pages DROP CONSTRAINT IF EXISTS content_pages_pkey;
ALTER TABLE IF EXISTS ONLY public.categories DROP CONSTRAINT IF EXISTS categories_new_pkey;
ALTER TABLE IF EXISTS ONLY public.categories DROP CONSTRAINT IF EXISTS categories_new_name_key;
ALTER TABLE IF EXISTS ONLY public.cart_items DROP CONSTRAINT IF EXISTS cart_items_pkey;
ALTER TABLE IF EXISTS ONLY public.bought_goods DROP CONSTRAINT IF EXISTS bought_goods_unique_id_key;
ALTER TABLE IF EXISTS ONLY public.bought_goods DROP CONSTRAINT IF EXISTS bought_goods_pkey;
ALTER TABLE IF EXISTS ONLY public.audit_log DROP CONSTRAINT IF EXISTS audit_log_pkey;
ALTER TABLE IF EXISTS ONLY public.alembic_version DROP CONSTRAINT IF EXISTS alembic_version_pkc;
ALTER TABLE IF EXISTS public.users ALTER COLUMN telegram_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.storefront_settings ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.stock_subscriptions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.roles ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.reviews ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.referral_earnings ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.promo_codes ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.promo_code_usages ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.payments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.operations ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.media_vault ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.media_capture_settings ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.item_values ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.goods ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.gacha_user_wins ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.gacha_settings ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.gacha_items ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.content_pages ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.categories ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.cart_items ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.bought_goods ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.audit_log ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.users_telegram_id_seq;
DROP TABLE IF EXISTS public.users;
DROP SEQUENCE IF EXISTS public.storefront_settings_id_seq;
DROP TABLE IF EXISTS public.storefront_settings;
DROP SEQUENCE IF EXISTS public.stock_subscriptions_id_seq;
DROP TABLE IF EXISTS public.stock_subscriptions;
DROP SEQUENCE IF EXISTS public.roles_id_seq;
DROP TABLE IF EXISTS public.roles;
DROP SEQUENCE IF EXISTS public.reviews_id_seq;
DROP TABLE IF EXISTS public.reviews;
DROP SEQUENCE IF EXISTS public.referral_earnings_id_seq;
DROP TABLE IF EXISTS public.referral_earnings;
DROP SEQUENCE IF EXISTS public.promo_codes_id_seq;
DROP TABLE IF EXISTS public.promo_codes;
DROP SEQUENCE IF EXISTS public.promo_code_usages_id_seq;
DROP TABLE IF EXISTS public.promo_code_usages;
DROP SEQUENCE IF EXISTS public.payments_id_seq;
DROP TABLE IF EXISTS public.payments;
DROP SEQUENCE IF EXISTS public.operations_id_seq;
DROP TABLE IF EXISTS public.operations;
DROP SEQUENCE IF EXISTS public.media_vault_id_seq;
DROP TABLE IF EXISTS public.media_vault;
DROP SEQUENCE IF EXISTS public.media_capture_settings_id_seq;
DROP TABLE IF EXISTS public.media_capture_settings;
DROP SEQUENCE IF EXISTS public.item_values_new_id_seq;
DROP TABLE IF EXISTS public.item_values;
DROP SEQUENCE IF EXISTS public.goods_new_id_seq;
DROP TABLE IF EXISTS public.goods;
DROP SEQUENCE IF EXISTS public.gacha_user_wins_id_seq;
DROP TABLE IF EXISTS public.gacha_user_wins;
DROP SEQUENCE IF EXISTS public.gacha_settings_id_seq;
DROP TABLE IF EXISTS public.gacha_settings;
DROP SEQUENCE IF EXISTS public.gacha_items_id_seq;
DROP TABLE IF EXISTS public.gacha_items;
DROP SEQUENCE IF EXISTS public.content_pages_id_seq;
DROP TABLE IF EXISTS public.content_pages;
DROP SEQUENCE IF EXISTS public.categories_new_id_seq;
DROP TABLE IF EXISTS public.categories;
DROP SEQUENCE IF EXISTS public.cart_items_id_seq;
DROP TABLE IF EXISTS public.cart_items;
DROP SEQUENCE IF EXISTS public.bought_goods_id_seq;
DROP TABLE IF EXISTS public.bought_goods;
DROP SEQUENCE IF EXISTS public.audit_log_id_seq;
DROP TABLE IF EXISTS public.audit_log;
DROP TABLE IF EXISTS public.alembic_version;
DROP EXTENSION IF EXISTS pg_trgm;
--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: shop_user
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO shop_user;

--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: shop_user
--

CREATE TABLE public.audit_log (
    id integer NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now() NOT NULL,
    level character varying(8) NOT NULL,
    user_id bigint,
    action character varying(64) NOT NULL,
    resource_type character varying(32),
    resource_id character varying(128),
    details text,
    ip_address character varying(45)
);


ALTER TABLE public.audit_log OWNER TO shop_user;

--
-- Name: audit_log_id_seq; Type: SEQUENCE; Schema: public; Owner: shop_user
--

CREATE SEQUENCE public.audit_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audit_log_id_seq OWNER TO shop_user;

--
-- Name: audit_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shop_user
--

ALTER SEQUENCE public.audit_log_id_seq OWNED BY public.audit_log.id;


--
-- Name: bought_goods; Type: TABLE; Schema: public; Owner: shop_user
--

CREATE TABLE public.bought_goods (
    id integer NOT NULL,
    item_name character varying(100) NOT NULL,
    value text NOT NULL,
    price numeric(12,2) NOT NULL,
    buyer_id bigint NOT NULL,
    bought_datetime timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    unique_id bigint NOT NULL,
    delivery_type character varying(12) DEFAULT 'text'::character varying NOT NULL,
    file_path text,
    file_name character varying(255)
);


ALTER TABLE public.bought_goods OWNER TO shop_user;

--
-- Name: bought_goods_id_seq; Type: SEQUENCE; Schema: public; Owner: shop_user
--

CREATE SEQUENCE public.bought_goods_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bought_goods_id_seq OWNER TO shop_user;

--
-- Name: bought_goods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shop_user
--

ALTER SEQUENCE public.bought_goods_id_seq OWNED BY public.bought_goods.id;


--
-- Name: cart_items; Type: TABLE; Schema: public; Owner: shop_user
--

CREATE TABLE public.cart_items (
    id integer NOT NULL,
    user_id bigint NOT NULL,
    promo_code character varying(50),
    added_at timestamp with time zone DEFAULT now() NOT NULL,
    item_id integer NOT NULL,
    quantity integer NOT NULL,
    CONSTRAINT ck_cart_items_quantity_positive CHECK ((quantity > 0))
);


ALTER TABLE public.cart_items OWNER TO shop_user;

--
-- Name: cart_items_id_seq; Type: SEQUENCE; Schema: public; Owner: shop_user
--

CREATE SEQUENCE public.cart_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cart_items_id_seq OWNER TO shop_user;

--
-- Name: cart_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shop_user
--

ALTER SEQUENCE public.cart_items_id_seq OWNED BY public.cart_items.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: shop_user
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.categories OWNER TO shop_user;

--
-- Name: categories_new_id_seq; Type: SEQUENCE; Schema: public; Owner: shop_user
--

CREATE SEQUENCE public.categories_new_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categories_new_id_seq OWNER TO shop_user;

--
-- Name: categories_new_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shop_user
--

ALTER SEQUENCE public.categories_new_id_seq OWNED BY public.categories.id;


--
-- Name: content_pages; Type: TABLE; Schema: public; Owner: shop_user
--

CREATE TABLE public.content_pages (
    id integer NOT NULL,
    button_text character varying(64) NOT NULL,
    content text NOT NULL,
    parent_id integer,
    media text,
    media_type character varying(16),
    is_active boolean DEFAULT true NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_content_pages_media_type CHECK (((media_type IS NULL) OR ((media_type)::text = ANY ((ARRAY['photo'::character varying, 'animation'::character varying, 'video'::character varying])::text[]))))
);


ALTER TABLE public.content_pages OWNER TO shop_user;

--
-- Name: content_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: shop_user
--

CREATE SEQUENCE public.content_pages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.content_pages_id_seq OWNER TO shop_user;

--
-- Name: content_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shop_user
--

ALTER SEQUENCE public.content_pages_id_seq OWNED BY public.content_pages.id;


--
-- Name: gacha_items; Type: TABLE; Schema: public; Owner: shop_user
--

CREATE TABLE public.gacha_items (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    item_type character varying(50) NOT NULL,
    reward_value text,
    drop_rate numeric(6,2) NOT NULL,
    stock_quantity integer NOT NULL,
    image_url text,
    is_active boolean NOT NULL,
    goods_id integer
);


ALTER TABLE public.gacha_items OWNER TO shop_user;

--
-- Name: gacha_items_id_seq; Type: SEQUENCE; Schema: public; Owner: shop_user
--

CREATE SEQUENCE public.gacha_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.gacha_items_id_seq OWNER TO shop_user;

--
-- Name: gacha_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shop_user
--

ALTER SEQUENCE public.gacha_items_id_seq OWNED BY public.gacha_items.id;


--
-- Name: gacha_settings; Type: TABLE; Schema: public; Owner: shop_user
--

CREATE TABLE public.gacha_settings (
    id integer NOT NULL,
    spin_price numeric(12,2) NOT NULL,
    is_active boolean NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    selected_item_ids text
);


ALTER TABLE public.gacha_settings OWNER TO shop_user;

--
-- Name: gacha_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: shop_user
--

CREATE SEQUENCE public.gacha_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.gacha_settings_id_seq OWNER TO shop_user;

--
-- Name: gacha_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shop_user
--

ALTER SEQUENCE public.gacha_settings_id_seq OWNED BY public.gacha_settings.id;


--
-- Name: gacha_user_wins; Type: TABLE; Schema: public; Owner: shop_user
--

CREATE TABLE public.gacha_user_wins (
    id integer NOT NULL,
    user_id bigint NOT NULL,
    gacha_item_id integer,
    item_name character varying(255) NOT NULL,
    reward_details text,
    won_at timestamp with time zone NOT NULL
);


ALTER TABLE public.gacha_user_wins OWNER TO shop_user;

--
-- Name: gacha_user_wins_id_seq; Type: SEQUENCE; Schema: public; Owner: shop_user
--

CREATE SEQUENCE public.gacha_user_wins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.gacha_user_wins_id_seq OWNER TO shop_user;

--
-- Name: gacha_user_wins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shop_user
--

ALTER SEQUENCE public.gacha_user_wins_id_seq OWNED BY public.gacha_user_wins.id;


--
-- Name: goods; Type: TABLE; Schema: public; Owner: shop_user
--

CREATE TABLE public.goods (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    price numeric(12,2) NOT NULL,
    description text NOT NULL,
    category_id integer NOT NULL,
    sale_percent numeric(5,2),
    sale_until timestamp with time zone,
    delivery_template text,
    restock_notification_template text
);


ALTER TABLE public.goods OWNER TO shop_user;

--
-- Name: goods_new_id_seq; Type: SEQUENCE; Schema: public; Owner: shop_user
--

CREATE SEQUENCE public.goods_new_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.goods_new_id_seq OWNER TO shop_user;

--
-- Name: goods_new_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shop_user
--

ALTER SEQUENCE public.goods_new_id_seq OWNED BY public.goods.id;


--
-- Name: item_values; Type: TABLE; Schema: public; Owner: shop_user
--

CREATE TABLE public.item_values (
    id integer NOT NULL,
    item_id integer NOT NULL,
    value text,
    is_infinity boolean NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    delivery_type character varying(12) DEFAULT 'text'::character varying NOT NULL,
    file_path text,
    file_name character varying(255),
    CONSTRAINT ck_item_values_quantity_positive CHECK ((quantity > 0))
);


ALTER TABLE public.item_values OWNER TO shop_user;

--
-- Name: item_values_new_id_seq; Type: SEQUENCE; Schema: public; Owner: shop_user
--

CREATE SEQUENCE public.item_values_new_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.item_values_new_id_seq OWNER TO shop_user;

--
-- Name: item_values_new_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shop_user
--

ALTER SEQUENCE public.item_values_new_id_seq OWNED BY public.item_values.id;


--
-- Name: media_capture_settings; Type: TABLE; Schema: public; Owner: shop_user
--

CREATE TABLE public.media_capture_settings (
    id integer NOT NULL,
    mode character varying(50) NOT NULL,
    allowed_user_ids text
);


ALTER TABLE public.media_capture_settings OWNER TO shop_user;

--
-- Name: media_capture_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: shop_user
--

CREATE SEQUENCE public.media_capture_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.media_capture_settings_id_seq OWNER TO shop_user;

--
-- Name: media_capture_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shop_user
--

ALTER SEQUENCE public.media_capture_settings_id_seq OWNED BY public.media_capture_settings.id;


--
-- Name: media_vault; Type: TABLE; Schema: public; Owner: shop_user
--

CREATE TABLE public.media_vault (
    id integer NOT NULL,
    file_id text NOT NULL,
    file_unique_id character varying(255),
    media_type character varying(50) NOT NULL,
    file_name character varying(255),
    file_size bigint,
    caption text,
    uploader_user_id bigint,
    created_at timestamp with time zone NOT NULL,
    converted_file_id text
);


ALTER TABLE public.media_vault OWNER TO shop_user;

--
-- Name: media_vault_id_seq; Type: SEQUENCE; Schema: public; Owner: shop_user
--

CREATE SEQUENCE public.media_vault_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.media_vault_id_seq OWNER TO shop_user;

--
-- Name: media_vault_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shop_user
--

ALTER SEQUENCE public.media_vault_id_seq OWNED BY public.media_vault.id;


--
-- Name: operations; Type: TABLE; Schema: public; Owner: shop_user
--

CREATE TABLE public.operations (
    id integer NOT NULL,
    user_id bigint,
    operation_value numeric(12,2) NOT NULL,
    operation_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.operations OWNER TO shop_user;

--
-- Name: operations_id_seq; Type: SEQUENCE; Schema: public; Owner: shop_user
--

CREATE SEQUENCE public.operations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.operations_id_seq OWNER TO shop_user;

--
-- Name: operations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shop_user
--

ALTER SEQUENCE public.operations_id_seq OWNED BY public.operations.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: shop_user
--

CREATE TABLE public.payments (
    id integer NOT NULL,
    provider character varying(32) NOT NULL,
    external_id character varying(128) NOT NULL,
    user_id bigint,
    amount numeric(12,2) NOT NULL,
    currency character varying(8) NOT NULL,
    status character varying(16) DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.payments OWNER TO shop_user;

--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: shop_user
--

CREATE SEQUENCE public.payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payments_id_seq OWNER TO shop_user;

--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shop_user
--

ALTER SEQUENCE public.payments_id_seq OWNED BY public.payments.id;


--
-- Name: promo_code_usages; Type: TABLE; Schema: public; Owner: shop_user
--

CREATE TABLE public.promo_code_usages (
    id integer NOT NULL,
    promo_id integer NOT NULL,
    user_id bigint NOT NULL,
    used_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.promo_code_usages OWNER TO shop_user;

--
-- Name: promo_code_usages_id_seq; Type: SEQUENCE; Schema: public; Owner: shop_user
--

CREATE SEQUENCE public.promo_code_usages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.promo_code_usages_id_seq OWNER TO shop_user;

--
-- Name: promo_code_usages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shop_user
--

ALTER SEQUENCE public.promo_code_usages_id_seq OWNED BY public.promo_code_usages.id;


--
-- Name: promo_codes; Type: TABLE; Schema: public; Owner: shop_user
--

CREATE TABLE public.promo_codes (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    discount_type character varying(10) NOT NULL,
    discount_value numeric(12,2) NOT NULL,
    max_uses integer DEFAULT 0 NOT NULL,
    current_uses integer DEFAULT 0 NOT NULL,
    expires_at timestamp with time zone,
    category_id integer,
    item_id integer,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    scope character varying(16) DEFAULT 'global'::character varying NOT NULL,
    CONSTRAINT ck_promo_codes_scope CHECK (((scope)::text = ANY ((ARRAY['global'::character varying, 'category'::character varying, 'item'::character varying])::text[]))),
    CONSTRAINT ck_promo_discount_nonneg CHECK ((discount_value >= (0)::numeric)),
    CONSTRAINT ck_promo_single_binding CHECK (((category_id IS NULL) OR (item_id IS NULL)))
);


ALTER TABLE public.promo_codes OWNER TO shop_user;

--
-- Name: promo_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: shop_user
--

CREATE SEQUENCE public.promo_codes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.promo_codes_id_seq OWNER TO shop_user;

--
-- Name: promo_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shop_user
--

ALTER SEQUENCE public.promo_codes_id_seq OWNED BY public.promo_codes.id;


--
-- Name: referral_earnings; Type: TABLE; Schema: public; Owner: shop_user
--

CREATE TABLE public.referral_earnings (
    id integer NOT NULL,
    referrer_id bigint NOT NULL,
    referral_id bigint NOT NULL,
    amount numeric(12,2) NOT NULL,
    original_amount numeric(12,2) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_referral_earnings_no_self_referral CHECK ((referrer_id <> referral_id))
);


ALTER TABLE public.referral_earnings OWNER TO shop_user;

--
-- Name: referral_earnings_id_seq; Type: SEQUENCE; Schema: public; Owner: shop_user
--

CREATE SEQUENCE public.referral_earnings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.referral_earnings_id_seq OWNER TO shop_user;

--
-- Name: referral_earnings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shop_user
--

ALTER SEQUENCE public.referral_earnings_id_seq OWNED BY public.referral_earnings.id;


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: shop_user
--

CREATE TABLE public.reviews (
    id integer NOT NULL,
    user_id bigint NOT NULL,
    rating integer NOT NULL,
    text text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    item_id integer NOT NULL,
    CONSTRAINT ck_review_rating_range CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.reviews OWNER TO shop_user;

--
-- Name: reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: shop_user
--

CREATE SEQUENCE public.reviews_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reviews_id_seq OWNER TO shop_user;

--
-- Name: reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shop_user
--

ALTER SEQUENCE public.reviews_id_seq OWNED BY public.reviews.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: shop_user
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying(64),
    "default" boolean,
    permissions integer
);


ALTER TABLE public.roles OWNER TO shop_user;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: shop_user
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO shop_user;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shop_user
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: stock_subscriptions; Type: TABLE; Schema: public; Owner: shop_user
--

CREATE TABLE public.stock_subscriptions (
    id integer NOT NULL,
    user_id bigint NOT NULL,
    item_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.stock_subscriptions OWNER TO shop_user;

--
-- Name: stock_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: shop_user
--

CREATE SEQUENCE public.stock_subscriptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.stock_subscriptions_id_seq OWNER TO shop_user;

--
-- Name: stock_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shop_user
--

ALTER SEQUENCE public.stock_subscriptions_id_seq OWNED BY public.stock_subscriptions.id;


--
-- Name: storefront_settings; Type: TABLE; Schema: public; Owner: shop_user
--

CREATE TABLE public.storefront_settings (
    id integer NOT NULL,
    main_menu_description text,
    shop_description text,
    extra_descriptions text
);


ALTER TABLE public.storefront_settings OWNER TO shop_user;

--
-- Name: storefront_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: shop_user
--

CREATE SEQUENCE public.storefront_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.storefront_settings_id_seq OWNER TO shop_user;

--
-- Name: storefront_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shop_user
--

ALTER SEQUENCE public.storefront_settings_id_seq OWNED BY public.storefront_settings.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: shop_user
--

CREATE TABLE public.users (
    telegram_id bigint NOT NULL,
    role_id integer,
    balance numeric(12,2) DEFAULT '0'::numeric NOT NULL,
    referral_id bigint,
    registration_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_blocked boolean,
    language character varying(8) DEFAULT 'vi'::character varying NOT NULL,
    CONSTRAINT ck_users_language CHECK (((language)::text = ANY ((ARRAY['vi'::character varying, 'en'::character varying, 'ru'::character varying])::text[]))),
    CONSTRAINT ck_users_no_self_referral CHECK ((referral_id <> telegram_id))
);


ALTER TABLE public.users OWNER TO shop_user;

--
-- Name: users_telegram_id_seq; Type: SEQUENCE; Schema: public; Owner: shop_user
--

CREATE SEQUENCE public.users_telegram_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_telegram_id_seq OWNER TO shop_user;

--
-- Name: users_telegram_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shop_user
--

ALTER SEQUENCE public.users_telegram_id_seq OWNED BY public.users.telegram_id;


--
-- Name: audit_log id; Type: DEFAULT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.audit_log ALTER COLUMN id SET DEFAULT nextval('public.audit_log_id_seq'::regclass);


--
-- Name: bought_goods id; Type: DEFAULT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.bought_goods ALTER COLUMN id SET DEFAULT nextval('public.bought_goods_id_seq'::regclass);


--
-- Name: cart_items id; Type: DEFAULT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.cart_items ALTER COLUMN id SET DEFAULT nextval('public.cart_items_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_new_id_seq'::regclass);


--
-- Name: content_pages id; Type: DEFAULT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.content_pages ALTER COLUMN id SET DEFAULT nextval('public.content_pages_id_seq'::regclass);


--
-- Name: gacha_items id; Type: DEFAULT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.gacha_items ALTER COLUMN id SET DEFAULT nextval('public.gacha_items_id_seq'::regclass);


--
-- Name: gacha_settings id; Type: DEFAULT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.gacha_settings ALTER COLUMN id SET DEFAULT nextval('public.gacha_settings_id_seq'::regclass);


--
-- Name: gacha_user_wins id; Type: DEFAULT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.gacha_user_wins ALTER COLUMN id SET DEFAULT nextval('public.gacha_user_wins_id_seq'::regclass);


--
-- Name: goods id; Type: DEFAULT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.goods ALTER COLUMN id SET DEFAULT nextval('public.goods_new_id_seq'::regclass);


--
-- Name: item_values id; Type: DEFAULT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.item_values ALTER COLUMN id SET DEFAULT nextval('public.item_values_new_id_seq'::regclass);


--
-- Name: media_capture_settings id; Type: DEFAULT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.media_capture_settings ALTER COLUMN id SET DEFAULT nextval('public.media_capture_settings_id_seq'::regclass);


--
-- Name: media_vault id; Type: DEFAULT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.media_vault ALTER COLUMN id SET DEFAULT nextval('public.media_vault_id_seq'::regclass);


--
-- Name: operations id; Type: DEFAULT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.operations ALTER COLUMN id SET DEFAULT nextval('public.operations_id_seq'::regclass);


--
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- Name: promo_code_usages id; Type: DEFAULT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.promo_code_usages ALTER COLUMN id SET DEFAULT nextval('public.promo_code_usages_id_seq'::regclass);


--
-- Name: promo_codes id; Type: DEFAULT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.promo_codes ALTER COLUMN id SET DEFAULT nextval('public.promo_codes_id_seq'::regclass);


--
-- Name: referral_earnings id; Type: DEFAULT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.referral_earnings ALTER COLUMN id SET DEFAULT nextval('public.referral_earnings_id_seq'::regclass);


--
-- Name: reviews id; Type: DEFAULT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.reviews ALTER COLUMN id SET DEFAULT nextval('public.reviews_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: stock_subscriptions id; Type: DEFAULT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.stock_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.stock_subscriptions_id_seq'::regclass);


--
-- Name: storefront_settings id; Type: DEFAULT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.storefront_settings ALTER COLUMN id SET DEFAULT nextval('public.storefront_settings_id_seq'::regclass);


--
-- Name: users telegram_id; Type: DEFAULT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.users ALTER COLUMN telegram_id SET DEFAULT nextval('public.users_telegram_id_seq'::regclass);


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: shop_user
--

COPY public.alembic_version (version_num) FROM stdin;
a9b8c7d6e5f4
\.


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: public; Owner: shop_user
--

COPY public.audit_log (id, "timestamp", level, user_id, action, resource_type, resource_id, details, ip_address) FROM stdin;
1	2026-07-19 22:10:58.972802+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
2	2026-07-19 22:12:35.405136+07	INFO	\N	sqladmin_create	Category	1	Categories(id=1, name='Gpt K12 ')	127.0.0.1
3	2026-07-19 22:14:11.735781+07	INFO	\N	sqladmin_create	Product	1	Goods(id=1, name='GPT k12 KBH Sieeu rer ', price=Decimal('12.000'), description='🎓 GPT K12\\r\\n\\r\\n📚 Trợ lý AI giáo dục thông minh dành cho học sinh, giáo viên và phụ huynh.\\r\\n\\r\\n✨ Hỗ trợ giải bài tập • Giải thích kiến thức • Luyện ngoại ngữ • Lập trình • Soạn tài liệu • Cá nhân hóa việc học với phản hồi nhanh, chính xác và dễ hiểu.', category_id=1, sale_percent=None, sale_until=None)	127.0.0.1
4	2026-07-19 22:14:25.384886+07	INFO	\N	sqladmin_create	Stock Item	1	ItemValues(id=1, item_id=1, is_infinity=False)	127.0.0.1
5	2026-07-19 22:15:25.73482+07	INFO	\N	sqladmin_create	Promo Code	1	PromoCodes(id=1, code='123456', discount_type='balance', discount_value=Decimal('100000'), scope='global', max_uses=100, current_uses=0, expires_at=None, category_id=None, item_id=None, is_active=False, created_at=datetime.datetime(2026, 7, 19, 15, 15, 25, 714164, tzinfo=datetime.timezone.utc))	127.0.0.1
6	2026-07-19 22:16:04.7488+07	INFO	\N	sqladmin_update	Promo Code	1	PromoCodes(id=1, code='123456', discount_type='balance', discount_value=Decimal('100000.00'), scope='global', max_uses=100, current_uses=0, expires_at=None, category_id=None, item_id=None, is_active=True, created_at=datetime.datetime(2026, 7, 19, 15, 15, 25, 714164, tzinfo=datetime.timezone.utc))	127.0.0.1
7	2026-07-20 14:56:22.135398+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
8	2026-07-20 14:56:30.077257+07	INFO	\N	web_logout	\N	\N	\N	127.0.0.1
9	2026-07-20 15:07:20.197564+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
10	2026-07-20 15:08:22.141768+07	INFO	7178345185	broadcast_sent	\N	\N	admin=Zijn, delivered=2/2, duration=1s	\N
11	2026-07-20 15:14:39.166167+07	INFO	\N	web_logout	\N	\N	\N	127.0.0.1
12	2026-07-20 15:14:41.242788+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
13	2026-07-20 15:21:26.756699+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
14	2026-07-20 16:09:41.463474+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
15	2026-07-20 16:43:42.741455+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
16	2026-07-20 17:02:02.802924+07	INFO	\N	sqladmin_create	Content Page	1	ContentPage(id=1, button_text='💳 Các phương thức thanh toán', content='💳 <b>THANH TOÁN</b>\\\\n\\\\nBot sẽ hiển thị các phương thức đang được admin bật.', parent_id=None, media='https://placehold.co/1200x630/4f46e5/ffffff?text=Telegram+Shop+Demo', media_type='photo', is_active=True, sort_order=1, created_at=datetime.datetime(2026, 7, 20, 12, 0))	127.0.0.1
17	2026-07-20 17:08:51.684648+07	INFO	\N	sqladmin_update	Content Page	1	ContentPage(id=1, button_text='💳 Các phương thức thanh toán', content='💳 <b>THANH TOÁN</b>\\\\n\\\\nBot sẽ hiển thị các phương thức đang được admin bật.', parent_id=None, media=None, media_type=None, is_active=True, sort_order=1, created_at=datetime.datetime(2026, 7, 20, 5, 0))	127.0.0.1
18	2026-07-20 17:09:38.707107+07	INFO	\N	sqladmin_delete	Category	1	Categories(id=1, name='Gpt K12 ')	127.0.0.1
19	2026-07-20 17:10:19.967746+07	INFO	\N	sqladmin_create	Category	2	Categories(id=2, name='📌 Chat GPT K12')	127.0.0.1
20	2026-07-20 17:10:46.694603+07	INFO	\N	sqladmin_create	Product	2	Goods(id=2, name='📌 HEHEHEHE ', price=Decimal('250000'), description='dfff', category_id=2, sale_percent=Decimal('-1'), sale_until=None)	127.0.0.1
21	2026-07-20 17:26:04.888132+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
22	2026-07-20 17:26:39.798425+07	INFO	\N	sqladmin_update	Content Page	1	ContentPage(id=1, button_text='💳 Các phương thức thanh toán', content='💳 <b>THANH TOÁN</b>\\\\n\\\\nBot sẽ hiển thị các phương thức đang được admin bật.', parent_id=None, media='https://tse2.mm.bing.net/th/id/OIP.DXvAngYNzNrgEpYP0AWZygHaEK?r=0&rs=1&pid=ImgDetMain&o=7&rm=3', media_type='photo', is_active=True, sort_order=1, created_at=datetime.datetime(2026, 7, 19, 22, 0))	127.0.0.1
23	2026-07-20 17:27:45.530912+07	INFO	\N	sqladmin_update	Content Page	1	ContentPage(id=1, button_text='💳 Các phương thức thanh toán', content='💳 <b>THANH TOÁN</b>\\\\n\\\\nBot sẽ hiển thị các phương thức đang được admin bật.', parent_id=None, media='https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExeDh4dDI4N3JlaGo5cWcwcGQ3dDNxNTFhazJtcWNobXc3cWJsMW11MiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/V69LhUggYIg6qmKUoD/giphy.gif', media_type='animation', is_active=True, sort_order=1, created_at=datetime.datetime(2026, 7, 19, 15, 0))	127.0.0.1
24	2026-07-20 17:28:52.951529+07	INFO	\N	sqladmin_update	Content Page	1	ContentPage(id=1, button_text='💳 Các phương thức thanh toán', content='💳 <b>THANH TOÁN</b>\\\\n\\\\nBot sẽ hiển thị các phương thức đang được admin bật.', parent_id=None, media='https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExeDh4dDI4N3JlaGo5cWcwcGQ3dDNxNTFhazJtcWNobXc3cWJsMW11MiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/V69LhUggYIg6qmKUoD/giphy.gif', media_type='animation', is_active=True, sort_order=1, created_at=datetime.datetime(2026, 7, 19, 8, 0))	127.0.0.1
25	2026-07-20 18:01:47.096998+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
26	2026-07-20 18:01:47.143264+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
27	2026-07-20 18:02:31.653776+07	INFO	\N	sqladmin_update	Content Page	1	ContentPage(id=1, button_text='💳 Các phương thức thanh toán', content='💳 <b>THANH TOÁN</b>\\\\n\\\\nBot sẽ hiển thị các<b> phương <blockquote expandable>thức đang </blockquote>được </b><tg-spoiler><tg-spoiler>admin bật.</tg-spoiler></tg-spoiler>', parent_id=None, media='https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExeDh4dDI4N3JlaGo5cWcwcGQ3dDNxNTFhazJtcWNobXc3cWJsMW11MiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/V69LhUggYIg6qmKUoD/giphy.gif', media_type='animation', is_active=True, sort_order=1, cre	127.0.0.1
28	2026-07-20 18:03:40.02301+07	INFO	\N	sqladmin_update	Content Page	1	ContentPage(id=1, button_text='💳 Các phương thức thanh toán', content='💳 <b>THANH TOÁN</b>- \\r\\n<b>Đây là gần như toàn bộ</b> \\r\\n<blockquote expandable>các định dạng\\r\\n văn bản chính\\r\\n thức mà Telegram Bot API hỗ trợ \\r\\n<i>khi gửi tin nhắn bằng</i>\\r\\n</blockquote>', parent_id=None, media='https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExeDh4dDI4N3JlaGo5cWcwcGQ3dDNxNTFhazJtcWNobXc3cWJsMW11MiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/V69LhUggYIg6qmKUoD/giphy.gif', media_type='animation', is_a	127.0.0.1
29	2026-07-20 18:55:31.550446+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
30	2026-07-20 19:11:31.782261+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
122	2026-07-22 17:35:40.019815+07	INFO	\N	sqladmin_create	Stock Item	20	ItemValues(id=20, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
124	2026-07-22 17:35:40.082481+07	INFO	\N	sqladmin_create	Stock Item	22	ItemValues(id=22, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
125	2026-07-22 17:35:40.109119+07	INFO	\N	sqladmin_create	Stock Item	23	ItemValues(id=23, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
31	2026-07-20 19:23:37.612271+07	INFO	\N	sqladmin_update	Storefront Settings	1	StorefrontSettings(id=1, main_menu_description='<b>🚀 CHÀO MỪNG BẠN ĐẾN VỚI PREMIUM ACCOUNT STORE</b>\\r\\n\\r\\n<i>Nơi cung cấp tài khoản số, gói Premium và các dịch vụ trực tuyến nhanh chóng, tiện lợi, minh bạch.</i>\\r\\n\\r\\n<blockquote>\\r\\n💎 Sản phẩm đa dạng  \\r\\n⚡ Giao hàng nhanh chóng  \\r\\n🛡️ Chính sách bảo hành rõ ràng  \\r\\n🤝 Hỗ trợ khách hàng tận tâm  \\r\\n💰 Giá cả cạnh tranh\\r\\n</blockquote>\\r\\n\\r\\n<b>🛒 SẢN PHẨM TẠI SHOP</b>\\r\\n\\r\\n✅ Tài khoản Premium theo thời hạn\\r\\n✅ Gói nâng cấp chính chủ\\r	127.0.0.1
32	2026-07-20 20:58:19.121252+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
33	2026-07-20 20:58:48.871985+07	INFO	\N	sqladmin_update	Storefront Settings	1	StorefrontSettings(id=1, main_menu_description='<b>🚀 CHÀO MỪNG BẠN ĐẾN VỚI PREMIUM ACCOUNT STORE</b>\\r\\n\\r\\n<i>Nơi cung cấp tài khoản số, gói Premium và các dịch vụ trực tuyến nhanh chóng, tiện lợi, minh bạch.</i>\\r\\n\\r\\n<blockquote>\\r\\n💎 Sản phẩm đa dạng  \\r\\n⚡ Giao hàng nhanh chóng  \\r\\n🛡️ Chính sách bảo hành rõ ràng  \\r\\n🤝 Hỗ trợ khách hàng tận tâm  \\r\\n💰 Giá cả cạnh tranh\\r\\n</blockquote>\\r\\n\\r\\n<b>🛒 SẢN PHẨM TẠI SHOP</b>\\r\\n\\r\\n✅ Tài khoản Premium theo thời hạn\\r\\n✅ Gói nâng cấp chính chủ\\r	127.0.0.1
34	2026-07-20 21:42:45.767318+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
35	2026-07-20 21:42:56.422823+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
36	2026-07-20 21:43:04.616183+07	INFO	\N	sqladmin_create	Stock Item	2	ItemValues(id=2, item_id=2, is_infinity=False)	127.0.0.1
37	2026-07-20 21:43:10.245067+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
38	2026-07-20 21:43:16.259911+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
39	2026-07-20 21:43:32.283544+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
40	2026-07-20 21:43:36.076806+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
41	2026-07-20 22:34:26.705813+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
42	2026-07-20 22:34:42.363131+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
43	2026-07-20 22:57:30.100181+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
44	2026-07-20 23:09:00.235442+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
45	2026-07-20 23:09:36.202389+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
46	2026-07-20 23:09:40.89963+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
47	2026-07-20 23:21:02.464753+07	INFO	7178345185	promo_redeem	PromoCode	123456	\N	\N
48	2026-07-20 23:21:10.808261+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
49	2026-07-20 23:21:40.384578+07	INFO	\N	sqladmin_update	Product	2	Goods(id=2, name='📌 HEHEHEHE', price=Decimal('2500'), description='dfff', category_id=2, sale_percent=Decimal('-1.00'), sale_until=None)	127.0.0.1
50	2026-07-20 23:22:05.220453+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
51	2026-07-20 23:22:06.667909+07	INFO	7178345185	purchase	Item	📌 HEHEHEHE	name=Zijn, price=2500.0 VND, unique_id=1935736604978422278	\N
52	2026-07-20 23:22:18.100581+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
53	2026-07-20 23:22:19.446193+07	INFO	7178345185	purchase	Item	📌 HEHEHEHE	name=Zijn, price=2500.0 VND, unique_id=3330575204350402590	\N
54	2026-07-20 23:22:23.179718+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
55	2026-07-20 23:22:24.508937+07	INFO	7178345185	purchase	Item	📌 HEHEHEHE	name=Zijn, price=2500.0 VND, unique_id=4656535913995412736	\N
56	2026-07-21 11:32:58.077084+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
57	2026-07-21 16:56:29.475856+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
58	2026-07-21 17:37:22.458113+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
59	2026-07-21 17:37:31.972181+07	INFO	\N	sqladmin_delete	Stock Item	2	ItemValues(id=2, item_id=2, is_infinity=False, quantity=97, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
60	2026-07-21 17:38:25.051198+07	INFO	\N	sqladmin_create	Stock Item	3	ItemValues(id=3, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
61	2026-07-21 17:38:25.075818+07	INFO	\N	sqladmin_create	Stock Item	4	ItemValues(id=4, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
62	2026-07-21 17:38:25.432282+07	INFO	\N	sqladmin_create	Stock Item	5	ItemValues(id=5, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
63	2026-07-21 17:38:25.477047+07	INFO	\N	sqladmin_create	Stock Item	6	ItemValues(id=6, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
64	2026-07-21 17:38:25.514846+07	INFO	\N	sqladmin_create	Stock Item	7	ItemValues(id=7, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
65	2026-07-21 17:38:25.599276+07	INFO	\N	sqladmin_create	Stock Item	8	ItemValues(id=8, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
66	2026-07-21 17:38:25.666806+07	INFO	\N	sqladmin_create	Stock Item	9	ItemValues(id=9, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
67	2026-07-21 17:38:25.749306+07	INFO	\N	sqladmin_create	Stock Item	10	ItemValues(id=10, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
68	2026-07-21 17:38:25.787451+07	INFO	\N	sqladmin_create	Stock Item	11	ItemValues(id=11, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
69	2026-07-21 17:38:25.819879+07	INFO	\N	sqladmin_create	Stock Item	12	ItemValues(id=12, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
70	2026-07-21 17:38:25.877947+07	INFO	\N	sqladmin_create	Stock Item	13	ItemValues(id=13, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
71	2026-07-21 17:38:25.927328+07	INFO	\N	sqladmin_create	Stock Item	14	ItemValues(id=14, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
72	2026-07-21 17:38:59.821193+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
73	2026-07-21 17:39:01.227189+07	INFO	7178345185	purchase	Item	📌 HEHEHEHE	name=Zijn, price=2500.0 VND, unique_id=2693078086819784657	\N
75	2026-07-21 17:41:25.237987+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
78	2026-07-21 17:47:08.911735+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
81	2026-07-21 17:48:04.297226+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
123	2026-07-22 17:35:40.051743+07	INFO	\N	sqladmin_create	Stock Item	21	ItemValues(id=21, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
283	2026-07-25 19:19:56.091414+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
74	2026-07-21 17:41:09.836796+07	INFO	\N	sqladmin_update	Product	2	Goods(id=2, name='📌 HEHEHEHE', price=Decimal('2500.00'), description='Đã sửa xong phần nhập kho.\\r\\nTrong Kho hàng → Thêm mới, bạn chọn “Cách nhập hàng”:\\r\\nMột nội dung text: chỉ hiện ô nội dung.\\r\\nMột tệp: chỉ hiện ô tải tệp, bắt buộc chọn tệp.\\r\\nMột nội dung text + tệp: hiện cả hai ô, bắt buộc đủ.\\r\\nNhiều tệp: chọn nhiều file một lần; mỗi file thành một hàng kho.\\r\\nFile text: tải một file .txt UTF-8; mỗi dòng không rỗng thành một hàng kho text.\\r\\n', category_id=2, sale_percent=Decimal('-	127.0.0.1
76	2026-07-21 17:41:26.842467+07	INFO	7178345185	purchase	Item	📌 HEHEHEHE	name=Zijn, price=2500.0 VND, unique_id=1161305546495600235	\N
79	2026-07-21 17:47:10.247178+07	INFO	7178345185	purchase	Item	📌 HEHEHEHE	name=Zijn, price=2500.0 VND, unique_id=8351978625058219729	\N
80	2026-07-21 17:47:55.141409+07	INFO	\N	sqladmin_update	Product	2	Goods(id=2, name='📌 HEHEHEHE', price=Decimal('2500.00'), description='Giờ nếu bạn bấm nút đó mà chưa chọn ô nào, nó sẽ tự chèn {{delivery}} vào ô Delivery Template. Nếu bạn đang đặt con trỏ trong một ô text khác, nó sẽ chèn vào đúng vị trí con trỏ ở ô đó. Đã kiểm tra 2 test giao diện đều qua.\\r\\nBạn restart web admin rồi tải lại mạnh trang bằng Ctrl + F5 để trình duyệt nhận JavaScript mới.\\r\\nDelivery Template nghĩa là “mẫu mô tả giao hàng” của từng sản phẩm: đây là đoạn tin nhắn cố định bot gửi	127.0.0.1
82	2026-07-21 17:48:05.634535+07	INFO	7178345185	purchase	Item	📌 HEHEHEHE	name=Zijn, price=2500.0 VND, unique_id=7170311778681202098	\N
77	2026-07-21 17:46:59.204007+07	INFO	\N	sqladmin_update	Product	2	Goods(id=2, name='📌 HEHEHEHE', price=Decimal('2500.00'), description='Đã sửa xong phần nhập kho.\\r\\nTrong Kho hàng → Thêm mới, bạn chọn “Cách nhập hàng”:\\r\\nMột nội dung text: chỉ hiện ô nội dung.\\r\\nMột tệp: chỉ hiện ô tải tệp, bắt buộc chọn tệp.\\r\\nMột nội dung text + tệp: hiện cả hai ô, bắt buộc đủ.\\r\\nNhiều tệp: chọn nhiều file một lần; mỗi file thành một hàng kho.\\r\\nFile text: tải một file .txt UTF-8; mỗi dòng không rỗng thành một hàng kho text.\\r\\n', category_id=2, sale_percent=Decimal('-	127.0.0.1
83	2026-07-21 17:52:48.173038+07	INFO	\N	sqladmin_update	Product	2	Goods(id=2, name='📌 HEHEHEHE', price=Decimal('2500.00'), description='xin chào ', category_id=2, sale_percent=Decimal('-1.00'), sale_until=None, delivery_template='Đã sửa xong phần nhập kho.\\r\\nTrong Kho hàng → Thêm mới, bạn chọn “Cách nhập hàng”:\\r\\nMột nội dung text: chỉ hiện ô nội dung.\\r\\nMột tệp: chỉ hiện ô tải tệp, bắt buộc chọn tệp.\\r\\nMột nội dung text + tệp: hiện cả hai ô, bắt buộc đủ.\\r\\n{{delivery}}\\r\\nNhiều tệp: chọn nhiều file một lần; mỗi file thành một hàng kho.\\r\\nFile text: tải 	127.0.0.1
84	2026-07-21 17:53:03.368479+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
85	2026-07-21 17:53:04.896979+07	INFO	7178345185	purchase	Item	📌 HEHEHEHE	name=Zijn, price=2500.0 VND, unique_id=2480958747479515903	\N
86	2026-07-21 17:53:48.825566+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
87	2026-07-21 17:53:50.141908+07	INFO	7178345185	purchase	Item	📌 HEHEHEHE	name=Zijn, price=2500.0 VND, unique_id=4298386746614096692	\N
88	2026-07-21 17:56:52.874847+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
89	2026-07-21 17:56:54.333616+07	INFO	7178345185	purchase	Item	📌 HEHEHEHE	name=Zijn, price=2500.0 VND, unique_id=559354470200321331	\N
90	2026-07-21 18:07:04.312016+07	INFO	\N	sqladmin_update	Product	2	Goods(id=2, name='📌 HEHEHEHE', price=Decimal('2500.00'), description='xin chào ', category_id=2, sale_percent=Decimal('-1.00'), sale_until=None, delivery_template='Đã sửa xong phần nhập kho.\\r\\nTrong Kho hàng → Thêm mới, bạn chọn “Cách nhập hàng”:\\r\\nMột nội dung text: chỉ hiện ô nội dung.\\r\\nMột tệp: chỉ hiện ô tải tệp, bắt buộc chọn tệp.\\r\\nMột nội dung text + tệp: hiện cả hai ô, bắt buộc đủ.\\r\\n{{delivery}}\\r\\nNhiều tệp: chọn nhiều file một lần; mỗi file thành một hàng kho.\\r\\nFile text: tải 	127.0.0.1
91	2026-07-21 18:07:12.916832+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
92	2026-07-21 18:07:14.335252+07	INFO	7178345185	purchase	Item	📌 HEHEHEHE	name=Zijn, price=2500.0 VND, unique_id=7391093720662876665	\N
93	2026-07-21 18:07:34.388052+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
94	2026-07-21 18:07:50.901706+07	INFO	\N	sqladmin_update	Product	2	Goods(id=2, name='📌 HEHEHEHE', price=Decimal('2500.00'), description='xin chào ', category_id=2, sale_percent=Decimal('-1.00'), sale_until=None, delivery_template='Đã sửa xong phần nhập kho.\\r\\nTrong Kho hàng → Thêm mới, bạn chọn “Cách nhập hàng”:\\r\\nMột nội dung text: chỉ hiện ô nội dung.\\r\\nMột tệp: chỉ hiện ô tải tệp, bắt buộc chọn tệp.\\r\\nMột nội dung text + tệp: hiện cả hai ô, bắt buộc đủ.\\r\\n<blockquote>{{delivery}}</blockquote>\\r\\nNhiều tệp: chọn nhiều file một lần; mỗi file thành một hàn	127.0.0.1
95	2026-07-21 18:07:58.400372+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
96	2026-07-21 18:07:59.684961+07	INFO	7178345185	purchase	Item	📌 HEHEHEHE	name=Zijn, price=2500.0 VND, unique_id=7630410723092571449	\N
97	2026-07-21 20:19:24.113446+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
98	2026-07-22 15:19:35.5176+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
99	2026-07-22 15:43:23.784876+07	INFO	7178345185	critical_action	\N	\N	callback=pay_payos	\N
100	2026-07-22 15:58:43.183387+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
101	2026-07-22 16:02:20.952537+07	INFO	7178345185	critical_action	\N	\N	callback=pay_payos	\N
102	2026-07-22 16:06:58.457889+07	INFO	7178345185	balance_replenish	Payment	\N	name=Zijn, amount=5000.00 VND, provider=payos	\N
103	2026-07-22 17:10:36.517449+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
104	2026-07-22 17:10:45.594885+07	INFO	\N	sqladmin_delete	Content Page	1	ContentPage(id=1, button_text='💳 Các phương thức thanh toán', content='💳 <b>THANH TOÁN</b>- \\r\\n<b>Đây là gần như toàn bộ</b> \\r\\n<blockquote expandable>các định dạng\\r\\n văn bản chính\\r\\n thức mà Telegram Bot API hỗ trợ \\r\\n<i>khi gửi tin nhắn bằng</i>\\r\\n</blockquote>', parent_id=None, media='https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExeDh4dDI4N3JlaGo5cWcwcGQ3dDNxNTFhazJtcWNobXc3cWJsMW11MiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/V69LhUggYIg6qmKUoD/giphy.gif', media_type='animation', is_a	127.0.0.1
105	2026-07-22 17:12:31.733833+07	INFO	6858166279	critical_action	\N	\N	callback=pay_payos	\N
106	2026-07-22 17:18:59.439062+07	INFO	6858166279	critical_action	\N	\N	callback=pay_payos	\N
107	2026-07-22 17:19:33.406142+07	INFO	6858166279	critical_action	\N	\N	callback=pay_payos	\N
108	2026-07-22 17:20:49.898125+07	INFO	6858166279	balance_replenish	Payment	\N	name=lucky star, amount=5000.00 VND, provider=payos	\N
109	2026-07-22 17:31:55.210028+07	INFO	6858166279	critical_action	\N	\N	callback=pay_payos	\N
110	2026-07-22 17:33:17.052352+07	INFO	6858166279	critical_action	\N	\N	callback=pay_payos	\N
111	2026-07-22 17:33:31.992343+07	INFO	6858166279	critical_action	\N	\N	callback=pay_payos	\N
112	2026-07-22 17:33:47.357431+07	INFO	6858166279	balance_replenish	Payment	\N	name=lucky star, amount=5000.00 VND, provider=payos	\N
113	2026-07-22 17:34:01.488248+07	INFO	6858166279	critical_action	\N	\N	callback=buy_item	\N
114	2026-07-22 17:34:02.467805+07	INFO	6858166279	purchase	Item	📌 HEHEHEHE	name=lucky star, price=2500.0 VND, unique_id=5354343392903997429	\N
115	2026-07-22 17:34:54.481465+07	INFO	6858166279	cart_checkout	Cart	\N	items=2, total=5000.00	\N
116	2026-07-22 17:35:09.823242+07	INFO	6858166279	critical_action	\N	\N	callback=buy_item	\N
117	2026-07-22 17:35:39.925532+07	INFO	\N	sqladmin_create	Stock Item	15	ItemValues(id=15, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
118	2026-07-22 17:35:39.944198+07	INFO	\N	sqladmin_create	Stock Item	16	ItemValues(id=16, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
119	2026-07-22 17:35:39.960923+07	INFO	\N	sqladmin_create	Stock Item	17	ItemValues(id=17, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
120	2026-07-22 17:35:39.978144+07	INFO	\N	sqladmin_create	Stock Item	18	ItemValues(id=18, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
121	2026-07-22 17:35:39.99655+07	INFO	\N	sqladmin_create	Stock Item	19	ItemValues(id=19, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
126	2026-07-22 17:35:40.137101+07	INFO	\N	sqladmin_create	Stock Item	24	ItemValues(id=24, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
128	2026-07-22 17:35:40.18846+07	INFO	\N	sqladmin_create	Stock Item	26	ItemValues(id=26, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
130	2026-07-22 17:35:40.249386+07	INFO	\N	sqladmin_create	Stock Item	28	ItemValues(id=28, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
132	2026-07-22 17:35:40.30448+07	INFO	\N	sqladmin_create	Stock Item	30	ItemValues(id=30, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
134	2026-07-22 17:35:40.353305+07	INFO	\N	sqladmin_create	Stock Item	32	ItemValues(id=32, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
136	2026-07-22 17:35:40.397895+07	INFO	\N	sqladmin_create	Stock Item	34	ItemValues(id=34, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
138	2026-07-22 17:35:40.437465+07	INFO	\N	sqladmin_create	Stock Item	36	ItemValues(id=36, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
140	2026-07-22 17:35:40.479364+07	INFO	\N	sqladmin_create	Stock Item	38	ItemValues(id=38, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
142	2026-07-22 17:35:40.524724+07	INFO	\N	sqladmin_create	Stock Item	40	ItemValues(id=40, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
144	2026-07-22 17:35:40.58327+07	INFO	\N	sqladmin_create	Stock Item	42	ItemValues(id=42, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
146	2026-07-22 17:35:40.644262+07	INFO	\N	sqladmin_create	Stock Item	44	ItemValues(id=44, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
148	2026-07-22 17:35:40.706479+07	INFO	\N	sqladmin_create	Stock Item	46	ItemValues(id=46, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
150	2026-07-22 17:35:40.762729+07	INFO	\N	sqladmin_create	Stock Item	48	ItemValues(id=48, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
152	2026-07-22 17:35:40.810411+07	INFO	\N	sqladmin_create	Stock Item	50	ItemValues(id=50, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
154	2026-07-22 17:35:40.857371+07	INFO	\N	sqladmin_create	Stock Item	52	ItemValues(id=52, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
156	2026-07-22 17:35:40.913034+07	INFO	\N	sqladmin_create	Stock Item	54	ItemValues(id=54, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
158	2026-07-22 17:35:40.964872+07	INFO	\N	sqladmin_create	Stock Item	56	ItemValues(id=56, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
160	2026-07-22 17:35:41.00197+07	INFO	\N	sqladmin_create	Stock Item	58	ItemValues(id=58, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
162	2026-07-22 17:35:41.047392+07	INFO	\N	sqladmin_create	Stock Item	60	ItemValues(id=60, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
164	2026-07-22 17:35:41.091235+07	INFO	\N	sqladmin_create	Stock Item	62	ItemValues(id=62, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
168	2026-07-22 17:36:10.380189+07	INFO	6858166279	cart_checkout	Cart	\N	items=3, total=7500.00	\N
127	2026-07-22 17:35:40.163107+07	INFO	\N	sqladmin_create	Stock Item	25	ItemValues(id=25, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
129	2026-07-22 17:35:40.220006+07	INFO	\N	sqladmin_create	Stock Item	27	ItemValues(id=27, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
131	2026-07-22 17:35:40.280514+07	INFO	\N	sqladmin_create	Stock Item	29	ItemValues(id=29, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
133	2026-07-22 17:35:40.328497+07	INFO	\N	sqladmin_create	Stock Item	31	ItemValues(id=31, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
135	2026-07-22 17:35:40.373861+07	INFO	\N	sqladmin_create	Stock Item	33	ItemValues(id=33, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
137	2026-07-22 17:35:40.416874+07	INFO	\N	sqladmin_create	Stock Item	35	ItemValues(id=35, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
139	2026-07-22 17:35:40.461707+07	INFO	\N	sqladmin_create	Stock Item	37	ItemValues(id=37, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
141	2026-07-22 17:35:40.498279+07	INFO	\N	sqladmin_create	Stock Item	39	ItemValues(id=39, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
143	2026-07-22 17:35:40.552391+07	INFO	\N	sqladmin_create	Stock Item	41	ItemValues(id=41, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
145	2026-07-22 17:35:40.613502+07	INFO	\N	sqladmin_create	Stock Item	43	ItemValues(id=43, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
147	2026-07-22 17:35:40.671578+07	INFO	\N	sqladmin_create	Stock Item	45	ItemValues(id=45, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
149	2026-07-22 17:35:40.736059+07	INFO	\N	sqladmin_create	Stock Item	47	ItemValues(id=47, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
151	2026-07-22 17:35:40.787693+07	INFO	\N	sqladmin_create	Stock Item	49	ItemValues(id=49, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
153	2026-07-22 17:35:40.830863+07	INFO	\N	sqladmin_create	Stock Item	51	ItemValues(id=51, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
155	2026-07-22 17:35:40.883743+07	INFO	\N	sqladmin_create	Stock Item	53	ItemValues(id=53, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
157	2026-07-22 17:35:40.940084+07	INFO	\N	sqladmin_create	Stock Item	55	ItemValues(id=55, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
159	2026-07-22 17:35:40.980821+07	INFO	\N	sqladmin_create	Stock Item	57	ItemValues(id=57, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
161	2026-07-22 17:35:41.027046+07	INFO	\N	sqladmin_create	Stock Item	59	ItemValues(id=59, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
163	2026-07-22 17:35:41.070288+07	INFO	\N	sqladmin_create	Stock Item	61	ItemValues(id=61, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
165	2026-07-22 17:35:41.114545+07	INFO	\N	sqladmin_create	Stock Item	63	ItemValues(id=63, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
166	2026-07-22 17:35:54.36634+07	INFO	6858166279	critical_action	\N	\N	callback=buy_item	\N
167	2026-07-22 17:35:55.79934+07	INFO	6858166279	purchase	Item	📌 HEHEHEHE	name=lucky star, price=2500.0 VND, unique_id=4806184549929427357	\N
169	2026-07-22 17:44:39.87021+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
170	2026-07-22 17:45:35.017542+07	INFO	\N	sqladmin_delete	Stock Item	19	ItemValues(id=19, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
171	2026-07-22 17:45:38.563095+07	INFO	\N	sqladmin_delete	Stock Item	20	ItemValues(id=20, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
172	2026-07-22 17:45:40.988917+07	INFO	\N	sqladmin_delete	Stock Item	21	ItemValues(id=21, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
173	2026-07-22 17:45:43.821325+07	INFO	\N	sqladmin_delete	Stock Item	22	ItemValues(id=22, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
174	2026-07-22 17:45:47.683284+07	INFO	\N	sqladmin_delete	Stock Item	23	ItemValues(id=23, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
175	2026-07-22 17:45:50.80229+07	INFO	\N	sqladmin_delete	Stock Item	24	ItemValues(id=24, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
176	2026-07-22 17:45:50.8172+07	INFO	\N	sqladmin_delete	Stock Item	25	ItemValues(id=25, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
177	2026-07-22 17:45:50.838736+07	INFO	\N	sqladmin_delete	Stock Item	26	ItemValues(id=26, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
178	2026-07-22 17:45:50.855468+07	INFO	\N	sqladmin_delete	Stock Item	27	ItemValues(id=27, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
179	2026-07-22 17:45:50.879878+07	INFO	\N	sqladmin_delete	Stock Item	28	ItemValues(id=28, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
180	2026-07-22 17:45:50.902419+07	INFO	\N	sqladmin_delete	Stock Item	29	ItemValues(id=29, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
181	2026-07-22 17:45:50.919856+07	INFO	\N	sqladmin_delete	Stock Item	30	ItemValues(id=30, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
182	2026-07-22 17:45:50.941309+07	INFO	\N	sqladmin_delete	Stock Item	31	ItemValues(id=31, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
183	2026-07-22 17:45:50.9661+07	INFO	\N	sqladmin_delete	Stock Item	32	ItemValues(id=32, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
184	2026-07-22 17:45:50.986027+07	INFO	\N	sqladmin_delete	Stock Item	33	ItemValues(id=33, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
185	2026-07-22 17:45:54.117896+07	INFO	\N	sqladmin_delete	Stock Item	34	ItemValues(id=34, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
284	2026-07-25 19:25:31.773822+07	INFO	\N	media_vault_cleanup	MediaVault	\N	Checked 2 file_ids, deleted 0 stale/expired file_ids	127.0.0.1
186	2026-07-22 17:45:54.135554+07	INFO	\N	sqladmin_delete	Stock Item	35	ItemValues(id=35, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
187	2026-07-22 17:45:54.15422+07	INFO	\N	sqladmin_delete	Stock Item	36	ItemValues(id=36, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
188	2026-07-22 17:45:54.172177+07	INFO	\N	sqladmin_delete	Stock Item	37	ItemValues(id=37, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
189	2026-07-22 17:45:54.185543+07	INFO	\N	sqladmin_delete	Stock Item	38	ItemValues(id=38, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
190	2026-07-22 17:45:54.209658+07	INFO	\N	sqladmin_delete	Stock Item	39	ItemValues(id=39, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
191	2026-07-22 17:45:54.234417+07	INFO	\N	sqladmin_delete	Stock Item	40	ItemValues(id=40, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
192	2026-07-22 17:45:54.25435+07	INFO	\N	sqladmin_delete	Stock Item	41	ItemValues(id=41, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
193	2026-07-22 17:45:54.270439+07	INFO	\N	sqladmin_delete	Stock Item	42	ItemValues(id=42, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
194	2026-07-22 17:45:54.286614+07	INFO	\N	sqladmin_delete	Stock Item	43	ItemValues(id=43, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
195	2026-07-22 17:45:57.633655+07	INFO	\N	sqladmin_delete	Stock Item	44	ItemValues(id=44, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
196	2026-07-22 17:45:57.653731+07	INFO	\N	sqladmin_delete	Stock Item	45	ItemValues(id=45, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
197	2026-07-22 17:45:57.671097+07	INFO	\N	sqladmin_delete	Stock Item	46	ItemValues(id=46, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
198	2026-07-22 17:45:57.690082+07	INFO	\N	sqladmin_delete	Stock Item	47	ItemValues(id=47, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
199	2026-07-22 17:45:57.707565+07	INFO	\N	sqladmin_delete	Stock Item	48	ItemValues(id=48, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
200	2026-07-22 17:45:57.726574+07	INFO	\N	sqladmin_delete	Stock Item	49	ItemValues(id=49, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
201	2026-07-22 17:45:57.745428+07	INFO	\N	sqladmin_delete	Stock Item	50	ItemValues(id=50, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
202	2026-07-22 17:45:57.78732+07	INFO	\N	sqladmin_delete	Stock Item	51	ItemValues(id=51, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
203	2026-07-22 17:45:57.814542+07	INFO	\N	sqladmin_delete	Stock Item	52	ItemValues(id=52, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
204	2026-07-22 17:45:57.835254+07	INFO	\N	sqladmin_delete	Stock Item	53	ItemValues(id=53, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
205	2026-07-22 17:46:01.199693+07	INFO	6858166279	critical_action	\N	\N	callback=buy_item	\N
206	2026-07-22 17:46:02.358737+07	INFO	6858166279	purchase	Item	📌 HEHEHEHE	name=lucky star, price=2500.0 VND, unique_id=5565078158752360403	\N
207	2026-07-22 17:46:28.83012+07	INFO	6858166279	critical_action	\N	\N	callback=buy_item	\N
208	2026-07-22 17:46:29.78913+07	INFO	6858166279	purchase	Item	📌 HEHEHEHE	name=lucky star, price=2500.0 VND, unique_id=952192981136713239	\N
209	2026-07-22 17:46:34.23628+07	INFO	6858166279	critical_action	\N	\N	callback=buy_item	\N
210	2026-07-22 17:46:35.200308+07	INFO	6858166279	purchase	Item	📌 HEHEHEHE	name=lucky star, price=2500.0 VND, unique_id=8281737595889493817	\N
211	2026-07-22 17:47:11.055199+07	INFO	6858166279	critical_action	\N	\N	callback=buy_item	\N
212	2026-07-22 17:47:12.194142+07	INFO	6858166279	purchase	Item	📌 HEHEHEHE	name=lucky star, price=2500.0 VND, unique_id=2864865142775948419	\N
213	2026-07-22 18:02:53.704755+07	INFO	6858166279	critical_action	\N	\N	callback=buy_item	\N
214	2026-07-22 20:59:57.022469+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
215	2026-07-22 21:00:04.740382+07	INFO	7178345185	purchase	Item	📌 HEHEHEHE	name=Zijn, price=2500.0 VND, unique_id=5952144490475627530	\N
216	2026-07-22 21:25:41.783575+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
217	2026-07-22 21:25:49.733092+07	INFO	7178345185	critical_action	\N	\N	callback=pay_payos	\N
218	2026-07-22 21:30:08.503463+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
219	2026-07-22 22:03:34.528883+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
220	2026-07-22 22:03:38.382651+07	INFO	7178345185	purchase	Item	📌 HEHEHEHE	name=Zijn, price=2500.0 VND, unique_id=4574397873892991165	\N
221	2026-07-22 22:03:45.216386+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
222	2026-07-22 22:03:47.332327+07	INFO	7178345185	purchase	Item	📌 HEHEHEHE	name=Zijn, price=2500.0 VND, unique_id=107456967212574391	\N
223	2026-07-22 22:04:50.288021+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
224	2026-07-22 22:04:59.869758+07	INFO	\N	sqladmin_delete	Stock Item	61	ItemValues(id=61, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
225	2026-07-22 22:04:59.898437+07	INFO	\N	sqladmin_delete	Stock Item	62	ItemValues(id=62, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
226	2026-07-22 22:04:59.927306+07	INFO	\N	sqladmin_delete	Stock Item	63	ItemValues(id=63, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
227	2026-07-22 22:05:32.982776+07	INFO	\N	sqladmin_create	Stock Item	64	ItemValues(id=64, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
228	2026-07-22 22:05:33.008479+07	INFO	\N	sqladmin_create	Stock Item	65	ItemValues(id=65, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
229	2026-07-22 22:05:33.25641+07	INFO	\N	sqladmin_create	Stock Item	66	ItemValues(id=66, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
230	2026-07-22 22:05:33.286072+07	INFO	\N	sqladmin_create	Stock Item	67	ItemValues(id=67, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
231	2026-07-22 22:05:33.323185+07	INFO	\N	sqladmin_create	Stock Item	68	ItemValues(id=68, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
232	2026-07-22 22:05:33.357294+07	INFO	\N	sqladmin_create	Stock Item	69	ItemValues(id=69, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
234	2026-07-22 22:05:33.415501+07	INFO	\N	sqladmin_create	Stock Item	71	ItemValues(id=71, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
236	2026-07-22 22:05:33.476243+07	INFO	\N	sqladmin_create	Stock Item	73	ItemValues(id=73, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
238	2026-07-22 22:05:33.525195+07	INFO	\N	sqladmin_create	Stock Item	75	ItemValues(id=75, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
240	2026-07-22 22:05:33.58672+07	INFO	\N	sqladmin_create	Stock Item	77	ItemValues(id=77, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
242	2026-07-22 22:05:33.648532+07	INFO	\N	sqladmin_create	Stock Item	79	ItemValues(id=79, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
244	2026-07-22 22:05:33.702984+07	INFO	\N	sqladmin_create	Stock Item	81	ItemValues(id=81, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
233	2026-07-22 22:05:33.387311+07	INFO	\N	sqladmin_create	Stock Item	70	ItemValues(id=70, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
235	2026-07-22 22:05:33.442267+07	INFO	\N	sqladmin_create	Stock Item	72	ItemValues(id=72, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
237	2026-07-22 22:05:33.505078+07	INFO	\N	sqladmin_create	Stock Item	74	ItemValues(id=74, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
239	2026-07-22 22:05:33.554692+07	INFO	\N	sqladmin_create	Stock Item	76	ItemValues(id=76, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
241	2026-07-22 22:05:33.618096+07	INFO	\N	sqladmin_create	Stock Item	78	ItemValues(id=78, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
243	2026-07-22 22:05:33.674833+07	INFO	\N	sqladmin_create	Stock Item	80	ItemValues(id=80, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
245	2026-07-22 22:05:33.726381+07	INFO	\N	sqladmin_create	Stock Item	82	ItemValues(id=82, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
246	2026-07-22 22:29:23.312582+07	INFO	\N	sqladmin_delete	Stock Item	64	ItemValues(id=64, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
247	2026-07-22 22:29:23.366532+07	INFO	\N	sqladmin_delete	Stock Item	65	ItemValues(id=65, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
248	2026-07-22 22:29:23.386126+07	INFO	\N	sqladmin_delete	Stock Item	66	ItemValues(id=66, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
249	2026-07-22 22:29:23.404327+07	INFO	\N	sqladmin_delete	Stock Item	67	ItemValues(id=67, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
250	2026-07-22 22:29:23.423602+07	INFO	\N	sqladmin_delete	Stock Item	68	ItemValues(id=68, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
251	2026-07-22 22:29:23.451278+07	INFO	\N	sqladmin_delete	Stock Item	69	ItemValues(id=69, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
252	2026-07-22 22:29:23.49449+07	INFO	\N	sqladmin_delete	Stock Item	70	ItemValues(id=70, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
253	2026-07-22 22:29:23.600822+07	INFO	\N	sqladmin_delete	Stock Item	71	ItemValues(id=71, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
254	2026-07-22 22:29:23.656937+07	INFO	\N	sqladmin_delete	Stock Item	72	ItemValues(id=72, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
255	2026-07-22 22:29:23.698548+07	INFO	\N	sqladmin_delete	Stock Item	73	ItemValues(id=73, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
256	2026-07-22 22:29:27.384571+07	INFO	\N	sqladmin_delete	Stock Item	74	ItemValues(id=74, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
257	2026-07-22 22:29:27.407865+07	INFO	\N	sqladmin_delete	Stock Item	75	ItemValues(id=75, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
258	2026-07-22 22:29:27.425976+07	INFO	\N	sqladmin_delete	Stock Item	76	ItemValues(id=76, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
259	2026-07-22 22:29:27.444978+07	INFO	\N	sqladmin_delete	Stock Item	77	ItemValues(id=77, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
260	2026-07-22 22:29:27.463451+07	INFO	\N	sqladmin_delete	Stock Item	78	ItemValues(id=78, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
261	2026-07-22 22:29:27.491831+07	INFO	\N	sqladmin_delete	Stock Item	79	ItemValues(id=79, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
262	2026-07-22 22:29:27.518237+07	INFO	\N	sqladmin_delete	Stock Item	80	ItemValues(id=80, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
263	2026-07-22 22:29:27.556239+07	INFO	\N	sqladmin_delete	Stock Item	81	ItemValues(id=81, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
264	2026-07-22 22:29:27.587185+07	INFO	\N	sqladmin_delete	Stock Item	82	ItemValues(id=82, item_id=2, is_infinity=False, quantity=1, delivery_type='text', file_path=None, file_name=None)	127.0.0.1
265	2026-07-22 22:36:28.526814+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
266	2026-07-22 22:36:28.700477+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
267	2026-07-23 16:55:47.138898+07	INFO	7178345185	critical_action	\N	\N	callback=buy_item	\N
268	2026-07-23 16:56:11.258285+07	INFO	7178345185	critical_action	\N	\N	callback=pay_payos	\N
269	2026-07-23 17:04:12.905714+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
270	2026-07-23 17:36:23.386318+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
271	2026-07-23 17:38:05.657875+07	INFO	7178345185	critical_action	\N	\N	callback=pay_payos	\N
272	2026-07-23 20:17:45.103026+07	INFO	7178345185	critical_action	\N	\N	callback=pay_payos	\N
273	2026-07-23 20:19:15.373935+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
274	2026-07-23 20:20:50.319648+07	INFO	\N	sqladmin_update	Gacha Item	1	GachaItem(id=1, name='💰 20.000 VND Số Dư', description='Cộng 20k vào tài khoản', item_type='balance_reward', reward_value='20000', drop_rate=Decimal('17'), stock_quantity=-1, image_url=None, is_active=True)	127.0.0.1
275	2026-07-23 22:31:35.955145+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
276	2026-07-24 17:19:58.624743+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
277	2026-07-25 17:39:06.531685+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
278	2026-07-25 18:10:19.386258+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
279	2026-07-25 18:15:28.193466+07	INFO	\N	gacha_settings_update	GachaSettings	1	Updated spin price to 10000.00	127.0.0.1
280	2026-07-25 18:16:27.352899+07	INFO	\N	sqladmin_create	Promo Code	2	PromoCodes(id=2, code='12345', discount_type='balance', discount_value=Decimal('100000000'), scope='global', max_uses=1, current_uses=0, expires_at=None, category_id=None, item_id=None, is_active=False, created_at=datetime.datetime(2026, 7, 25, 11, 16, 27, 336968, tzinfo=datetime.timezone.utc))	127.0.0.1
281	2026-07-25 18:16:45.916429+07	INFO	\N	sqladmin_update	Promo Code	2	PromoCodes(id=2, code='12345', discount_type='balance', discount_value=Decimal('100000000.00'), scope='global', max_uses=1, current_uses=0, expires_at=None, category_id=None, item_id=None, is_active=True, created_at=datetime.datetime(2026, 7, 25, 11, 16, 27, 336968, tzinfo=datetime.timezone.utc))	127.0.0.1
282	2026-07-25 18:16:59.176928+07	INFO	7178345185	promo_redeem	PromoCode	12345	\N	\N
285	2026-07-25 19:50:10.359435+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
286	2026-07-25 19:50:15.143667+07	INFO	\N	media_capture_settings_update	MediaCaptureSettings	\N	mode=allow_selected, allowed_users=[7178345185]	127.0.0.1
287	2026-07-25 19:50:18.847605+07	INFO	\N	media_capture_settings_update	MediaCaptureSettings	\N	mode=allow_selected, allowed_users=[7178345185]	127.0.0.1
288	2026-07-25 19:50:24.255052+07	INFO	\N	media_capture_settings_update	MediaCaptureSettings	\N	mode=allow_all, allowed_users=[]	127.0.0.1
289	2026-07-25 19:50:31.910767+07	INFO	\N	media_capture_settings_update	MediaCaptureSettings	\N	mode=allow_selected, allowed_users=[7178345185]	127.0.0.1
290	2026-07-25 19:50:34.789756+07	INFO	\N	media_capture_settings_update	MediaCaptureSettings	\N	mode=allow_all, allowed_users=[]	127.0.0.1
291	2026-07-25 20:23:21.363993+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
292	2026-07-25 20:23:30.450228+07	INFO	\N	media_capture_user_add	MediaCaptureSettings	\N	Added allowed user_id: 7178345185	127.0.0.1
293	2026-07-25 20:23:36.667664+07	INFO	\N	media_capture_settings_update	MediaCaptureSettings	\N	mode=allow_selected, allowed_users=[]	127.0.0.1
294	2026-07-25 20:23:43.238589+07	INFO	\N	media_capture_user_add	MediaCaptureSettings	\N	Added allowed user_id: 7178345185	127.0.0.1
295	2026-07-25 20:23:46.436533+07	INFO	\N	media_capture_settings_update	MediaCaptureSettings	\N	mode=allow_selected, allowed_users=[]	127.0.0.1
296	2026-07-25 20:23:48.933163+07	INFO	\N	media_capture_user_add	MediaCaptureSettings	\N	Added allowed user_id: 7178345185	127.0.0.1
297	2026-07-25 20:33:08.399209+07	INFO	\N	media_capture_settings_update	MediaCaptureSettings	\N	mode=allow_selected	127.0.0.1
298	2026-07-25 20:33:11.340294+07	INFO	\N	media_capture_settings_update	MediaCaptureSettings	\N	mode=allow_all	127.0.0.1
299	2026-07-25 20:33:13.336452+07	INFO	\N	media_capture_settings_update	MediaCaptureSettings	\N	mode=allow_selected	127.0.0.1
300	2026-07-25 20:33:15.587752+07	INFO	\N	media_capture_user_remove	MediaCaptureSettings	\N	Removed allowed user_id: 7178345185	127.0.0.1
301	2026-07-25 20:33:16.795543+07	INFO	\N	media_capture_settings_update	MediaCaptureSettings	\N	mode=allow_selected	127.0.0.1
302	2026-07-25 20:33:19.985416+07	INFO	\N	media_capture_settings_update	MediaCaptureSettings	\N	mode=allow_all	127.0.0.1
303	2026-07-25 20:33:21.686572+07	INFO	\N	media_capture_settings_update	MediaCaptureSettings	\N	mode=allow_selected	127.0.0.1
304	2026-07-25 20:33:40.929982+07	INFO	\N	media_capture_settings_update	MediaCaptureSettings	\N	mode=allow_all	127.0.0.1
305	2026-07-25 20:34:19.650303+07	INFO	\N	media_capture_user_add	MediaCaptureSettings	\N	Added allowed user_id: 7178345185	127.0.0.1
306	2026-07-25 20:34:21.488325+07	INFO	\N	media_capture_settings_update	MediaCaptureSettings	\N	mode=allow_selected	127.0.0.1
307	2026-07-25 20:35:09.084338+07	INFO	\N	media_vault_delete	MediaVault	4	AgACAgUAAxkBAAI	127.0.0.1
308	2026-07-25 20:35:18.9775+07	INFO	\N	media_vault_delete	MediaVault	1	AgACAgUAAxkBAAI	127.0.0.1
309	2026-07-25 20:39:10.779856+07	INFO	\N	media_capture_settings_update	MediaCaptureSettings	\N	mode=allow_all	127.0.0.1
310	2026-07-25 20:39:34.973867+07	INFO	\N	media_capture_settings_update	MediaCaptureSettings	\N	mode=allow_selected	127.0.0.1
311	2026-07-25 20:39:59.158678+07	INFO	\N	media_vault_delete	MediaVault	5	AgACAgUAAxkBAAI	127.0.0.1
312	2026-07-25 20:40:26.205367+07	INFO	\N	media_vault_delete	MediaVault	6	AgACAgUAAxkBAAI	127.0.0.1
313	2026-07-25 21:15:32.900547+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
314	2026-07-25 21:33:56.584943+07	INFO	\N	system_button_update	SystemButton	ngam_xinh	Updated description for ngam_xinh	127.0.0.1
315	2026-07-25 21:34:04.853267+07	INFO	\N	system_button_update	SystemButton	ngam_xinh	Updated description for ngam_xinh	127.0.0.1
316	2026-07-26 10:59:51.081471+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
317	2026-07-26 11:00:00.441505+07	INFO	\N	daily_cleanup	\N	\N	audit_deleted=0, payments_deleted=0, media_checked=2, media_deleted=0	\N
318	2026-07-26 12:22:45.188114+07	INFO	\N	web_login	\N	\N	user=admin	127.0.0.1
319	2026-07-26 12:22:58.228321+07	INFO	\N	media_capture_settings_update	MediaCaptureSettings	\N	mode=block_all	127.0.0.1
320	2026-07-26 12:24:11.034216+07	INFO	\N	media_capture_settings_update	MediaCaptureSettings	\N	mode=allow_all	127.0.0.1
321	2026-07-26 12:24:55.075222+07	INFO	\N	media_vault_delete	MediaVault	58	AgACAgUAAxkBAAI	127.0.0.1
322	2026-07-26 12:25:01.941671+07	INFO	\N	media_capture_settings_update	MediaCaptureSettings	\N	mode=block_all	127.0.0.1
323	2026-07-26 12:25:20.10802+07	INFO	\N	media_capture_settings_update	MediaCaptureSettings	\N	mode=allow_selected	127.0.0.1
\.


--
-- Data for Name: bought_goods; Type: TABLE DATA; Schema: public; Owner: shop_user
--

COPY public.bought_goods (id, item_name, value, price, buyer_id, bought_datetime, unique_id, delivery_type, file_path, file_name) FROM stdin;
1	📌 HEHEHEHE	100	2500.00	7178345185	2026-07-20 23:22:05.645308+07	1935736604978422278	text	\N	\N
2	📌 HEHEHEHE	100	2500.00	7178345185	2026-07-20 23:22:18.62651+07	3330575204350402590	text	\N	\N
3	📌 HEHEHEHE	100	2500.00	7178345185	2026-07-20 23:22:23.671049+07	4656535913995412736	text	\N	\N
4	📌 HEHEHEHE	10-03-26 :	2500.00	7178345185	2026-07-21 17:39:00.259163+07	2693078086819784657	text	\N	\N
5	📌 HEHEHEHE	- Tối ưu lại hệ thống cho chạy mượt mà hơn :	2500.00	7178345185	2026-07-21 17:41:25.764404+07	1161305546495600235	text	\N	\N
6	📌 HEHEHEHE	+ Tối ưu lại broker server	2500.00	7178345185	2026-07-21 17:47:09.370607+07	8351978625058219729	text	\N	\N
7	📌 HEHEHEHE	Đã xong : Đã chuyển thành async bất đồng bộ .	2500.00	7178345185	2026-07-21 17:48:04.797025+07	7170311778681202098	text	\N	\N
8	📌 HEHEHEHE	Đã dò xét xong code , không có lỗi gì trong service mqtt và file broker_mqtt .	2500.00	7178345185	2026-07-21 17:53:03.810163+07	2480958747479515903	text	\N	\N
9	📌 HEHEHEHE	Đã dò xét xong các API trong các file :  MQTT,	2500.00	7178345185	2026-07-21 17:53:49.332457+07	4298386746614096692	text	\N	\N
10	📌 HEHEHEHE	AUTH , DEVICES, và các file liên quan tới broke_server	2500.00	7178345185	2026-07-21 17:56:53.360818+07	559354470200321331	text	\N	\N
11	📌 HEHEHEHE	- Vấn đề về web socket truyền âm thanh , thời gian mở websocket có thể mất từ 500 tới 1 giây  == > cần giải pháp để tránh hệ thống bị delay :	2500.00	7178345185	2026-07-21 18:07:13.339394+07	7391093720662876665	text	\N	\N
12	📌 HEHEHEHE	Kết nối sẵn và giữ nó sống (Keep-alive): Khi thiết bị khởi động và vào WiFi xong, mở ngay WebSocket và cứ để nó nằm đó (ngủ đông). Đừng gửi gì cả, thỉnh thoảng Server ping một cái để nó khỏi đứt.	2500.00	7178345185	2026-07-21 18:07:58.873746+07	7630410723092571449	text	\N	\N
13	📌 HEHEHEHE	Buffer cục bộ: Khi người dùng bắt đầu nói, ESP32 lưu tạm âm thanh vào một mảng trên RAM (thường là Ring Buffer), đồng thời check xem WebSocket còn sống không.	2500.00	6858166279	2026-07-22 17:34:01.885838+07	5354343392903997429	text	\N	\N
14	📌 HEHEHEHE	Nếu websocket vẫn sống (được giữ từ trước) -> Đổ data lên ngay lập tức đè qua stream (0 độ trễ).	2500.00	6858166279	2026-07-22 17:34:54.084804+07	4023985706635110181	text	\N	\N
15	📌 HEHEHEHE	Không nên: Thiết kế theo kiểu cứ bấm nút là tạo kết nối websocket.connect() -> nói -> nhả nút chặn kết nối -> .close(). Việc nhảy ra nhảy vào như thế sẽ giết chết hiệu suất của ESP32 và làm delay mất mát âm thanh!	2500.00	6858166279	2026-07-22 17:34:54.090448+07	5476650290276804371	text	\N	\N
16	📌 HEHEHEHE	⚠️ RẤT QUAN TRỌNG	2500.00	6858166279	2026-07-22 17:35:54.736359+07	4806184549929427357	text	\N	\N
17	📌 HEHEHEHE	D0–D7 + PCLK	2500.00	6858166279	2026-07-22 17:36:09.920877+07	928680600834712523	text	\N	\N
18	📌 HEHEHEHE	Đi ngắn	2500.00	6858166279	2026-07-22 17:36:09.926028+07	252758135030982513	text	\N	\N
19	📌 HEHEHEHE	Tránh chạy dưới crystal / switching regulator	2500.00	6858166279	2026-07-22 17:36:09.928004+07	8696264000989635514	text	\N	\N
20	📌 HEHEHEHE	🔹 Theo datasheet OV2640	2500.00	6858166279	2026-07-22 17:46:01.582511+07	5565078158752360403	text	\N	\N
21	📌 HEHEHEHE	Chân\tĐiện áp\tCách cấp	2500.00	6858166279	2026-07-22 17:46:29.210291+07	952192981136713239	text	\N	\N
22	📌 HEHEHEHE	AVDD\t2.8–3.3V\tTừ 3.3V qua ferrite bead + 0.1uF + 1uF	2500.00	6858166279	2026-07-22 17:46:34.609797+07	8281737595889493817	text	\N	\N
23	📌 HEHEHEHE	DOVDD\t1.7–2.8V\t3.3V trực tiếp (OK)	2500.00	6858166279	2026-07-22 17:47:11.428524+07	2864865142775948419	text	\N	\N
24	📌 HEHEHEHE	DVDD\t1.2–1.5V\tBẮT BUỘC LDO 1.2V	2500.00	7178345185	2026-07-22 21:00:03.852447+07	5952144490475627530	text	\N	\N
25	📌 HEHEHEHE	❌ Không được nối DVDD vào 3.3V	2500.00	7178345185	2026-07-22 22:03:37.484128+07	4574397873892991165	text	\N	\N
26	📌 HEHEHEHE	✔ Dùng ME6211-1.2V / TLV70012 / XC6206-1.2V	2500.00	7178345185	2026-07-22 22:03:46.729196+07	107456967212574391	text	\N	\N
\.


--
-- Data for Name: cart_items; Type: TABLE DATA; Schema: public; Owner: shop_user
--

COPY public.cart_items (id, user_id, promo_code, added_at, item_id, quantity) FROM stdin;
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: shop_user
--

COPY public.categories (id, name) FROM stdin;
2	📌 Chat GPT K12
\.


--
-- Data for Name: content_pages; Type: TABLE DATA; Schema: public; Owner: shop_user
--

COPY public.content_pages (id, button_text, content, parent_id, media, media_type, is_active, sort_order, created_at) FROM stdin;
\.


--
-- Data for Name: gacha_items; Type: TABLE DATA; Schema: public; Owner: shop_user
--

COPY public.gacha_items (id, name, description, item_type, reward_value, drop_rate, stock_quantity, image_url, is_active, goods_id) FROM stdin;
2	💰 50.000 VND Số Dư	Cộng 50k vào tài khoản	balance_reward	50000	5.00	-1	\N	t	\N
3	🎟️ Voucher Giảm Giá 20%	Mã giảm giá 20% khi mua hàng	promo_code	GACHA20	20.00	-1	\N	t	\N
4	🎁 Giftcode VIP 7 Ngày	Mã quà tặng VIP	text_gift	GIFTCODE-VIP7D-999	10.00	-1	\N	t	\N
5	😅 Chúc bạn may mắn lần sau	Không trúng thưởng	no_prize		50.00	-1	\N	t	\N
1	💰 20.000 VND Số Dư	Cộng 20k vào tài khoản	balance_reward	20000	17.00	-1	\N	t	\N
\.


--
-- Data for Name: gacha_settings; Type: TABLE DATA; Schema: public; Owner: shop_user
--

COPY public.gacha_settings (id, spin_price, is_active, title, description, selected_item_ids) FROM stdin;
1	10000.00	t	🎰 Vòng Quay Gacha May Mắn	Thử vận may ngay hôm nay với nhiều phần quà hấp dẫn!	[5, 3]
\.


--
-- Data for Name: gacha_user_wins; Type: TABLE DATA; Schema: public; Owner: shop_user
--

COPY public.gacha_user_wins (id, user_id, gacha_item_id, item_name, reward_details, won_at) FROM stdin;
2	7178345185	5	😅 Chúc bạn may mắn lần sau	Chúc bạn may mắn lần sau!	2026-07-23 20:16:48.314083+07
3	7178345185	4	🎁 Giftcode VIP 7 Ngày	GIFTCODE-VIP7D-999	2026-07-23 20:16:51.528466+07
5	7178345185	3	🎟️ Voucher Giảm Giá 20%	Mã giảm giá: GACHA20	2026-07-23 20:17:08.296517+07
6	7178345185	5	😅 Chúc bạn may mắn lần sau	Chúc bạn may mắn lần sau!	2026-07-23 20:17:10.217018+07
8	7178345185	5	😅 Chúc bạn may mắn lần sau	Chúc bạn may mắn lần sau!	2026-07-23 20:17:13.402912+07
9	7178345185	3	🎟️ Voucher Giảm Giá 20%	Mã giảm giá: GACHA20	2026-07-23 20:17:14.603926+07
10	7178345185	4	🎁 Giftcode VIP 7 Ngày	GIFTCODE-VIP7D-999	2026-07-23 20:17:15.855735+07
4	7178345185	1	🎟️ Voucher Giảm Giá 20%	Mã giảm giá: GACHA20	2026-07-23 20:16:58.814829+07
11	7178345185	5	😅 Chúc bạn may mắn lần sau	Chúc bạn may mắn lần sau! Đừng nản lòng nhé.	2026-07-25 18:17:07.499985+07
12	7178345185	5	😅 Chúc bạn may mắn lần sau	Chúc bạn may mắn lần sau! Đừng nản lòng nhé.	2026-07-25 18:17:10.509535+07
13	7178345185	5	😅 Chúc bạn may mắn lần sau	Chúc bạn may mắn lần sau! Đừng nản lòng nhé.	2026-07-25 18:17:11.769445+07
14	7178345185	5	😅 Chúc bạn may mắn lần sau	Chúc bạn may mắn lần sau! Đừng nản lòng nhé.	2026-07-25 18:17:12.727388+07
15	7178345185	5	😅 Chúc bạn may mắn lần sau	Chúc bạn may mắn lần sau! Đừng nản lòng nhé.	2026-07-25 18:17:13.586535+07
16	7178345185	5	😅 Chúc bạn may mắn lần sau	Chúc bạn may mắn lần sau! Đừng nản lòng nhé.	2026-07-25 18:17:14.463009+07
17	7178345185	5	😅 Chúc bạn may mắn lần sau	Chúc bạn may mắn lần sau! Đừng nản lòng nhé.	2026-07-25 18:17:15.277434+07
18	7178345185	5	😅 Chúc bạn may mắn lần sau	Chúc bạn may mắn lần sau! Đừng nản lòng nhé.	2026-07-25 18:17:20.811866+07
19	7178345185	5	😅 Chúc bạn may mắn lần sau	Chúc bạn may mắn lần sau! Đừng nản lòng nhé.	2026-07-25 18:17:21.970241+07
20	7178345185	5	😅 Chúc bạn may mắn lần sau	Chúc bạn may mắn lần sau! Đừng nản lòng nhé.	2026-07-25 18:17:22.921064+07
21	7178345185	3	🎟️ Voucher Giảm Giá 20%	Mã giảm giá GACHA20%	2026-07-25 18:17:23.713906+07
22	7178345185	5	😅 Chúc bạn may mắn lần sau	Chúc bạn may mắn lần sau! Đừng nản lòng nhé.	2026-07-25 18:17:25.050621+07
23	7178345185	5	😅 Chúc bạn may mắn lần sau	Chúc bạn may mắn lần sau! Đừng nản lòng nhé.	2026-07-25 18:17:25.847027+07
24	7178345185	5	😅 Chúc bạn may mắn lần sau	Chúc bạn may mắn lần sau! Đừng nản lòng nhé.	2026-07-25 18:17:26.56611+07
25	7178345185	5	😅 Chúc bạn may mắn lần sau	Chúc bạn may mắn lần sau! Đừng nản lòng nhé.	2026-07-25 18:17:29.084902+07
26	7178345185	5	😅 Chúc bạn may mắn lần sau	Chúc bạn may mắn lần sau! Đừng nản lòng nhé.	2026-07-25 18:17:30.33435+07
27	7178345185	5	😅 Chúc bạn may mắn lần sau	Chúc bạn may mắn lần sau! Đừng nản lòng nhé.	2026-07-25 18:17:30.524236+07
28	7178345185	5	😅 Chúc bạn may mắn lần sau	Chúc bạn may mắn lần sau! Đừng nản lòng nhé.	2026-07-25 18:17:30.950666+07
29	7178345185	5	😅 Chúc bạn may mắn lần sau	Chúc bạn may mắn lần sau! Đừng nản lòng nhé.	2026-07-25 18:17:31.242487+07
30	7178345185	5	😅 Chúc bạn may mắn lần sau	Chúc bạn may mắn lần sau! Đừng nản lòng nhé.	2026-07-25 18:17:35.19221+07
31	7178345185	3	🎟️ Voucher Giảm Giá 20%	Mã giảm giá GACHA20%	2026-07-25 18:17:35.528705+07
\.


--
-- Data for Name: goods; Type: TABLE DATA; Schema: public; Owner: shop_user
--

COPY public.goods (id, name, price, description, category_id, sale_percent, sale_until, delivery_template, restock_notification_template) FROM stdin;
2	📌 HEHEHEHE	2500.00	xin chào 	2	-1.00	\N	Đã sửa xong phần nhập kho.\r\nTrong Kho hàng → Thêm mới, bạn chọn “Cách nhập hàng”:\r\nMột nội dung text: chỉ hiện ô nội dung.\r\nMột tệp: chỉ hiện ô tải tệp, bắt buộc chọn tệp.\r\nMột nội dung text + tệp: hiện cả hai ô, bắt buộc đủ.\r\n<blockquote>{{delivery}}</blockquote>\r\nNhiều tệp: chọn nhiều file một lần; mỗi file thành một hàng kho.\r\nFile text: tải một file .txt UTF-8; mỗi dòng không rỗng thành một hàng kho text.	\N
\.


--
-- Data for Name: item_values; Type: TABLE DATA; Schema: public; Owner: shop_user
--

COPY public.item_values (id, item_id, value, is_infinity, quantity, delivery_type, file_path, file_name) FROM stdin;
\.


--
-- Data for Name: media_capture_settings; Type: TABLE DATA; Schema: public; Owner: shop_user
--

COPY public.media_capture_settings (id, mode, allowed_user_ids) FROM stdin;
1	allow_selected	[7178345185]
\.


--
-- Data for Name: media_vault; Type: TABLE DATA; Schema: public; Owner: shop_user
--

COPY public.media_vault (id, file_id, file_unique_id, media_type, file_name, file_size, caption, uploader_user_id, created_at, converted_file_id) FROM stdin;
2	BAACAgUAAxkBAAIBE2pkqslWsbfSz2PWGG7qOQpUxw3lAALWGwACTMgoV4ZPMnZ79iFPPQQ	AgAD1hsAAkzIKFc	video	5MC84RV2ZhaRjGhX.mp4	4904462	\N	7178345185	2026-07-25 19:23:38.03722+07	\N
7	BAACAgUAAxkBAAIBN2plhwiCm1KdGoVHYQ1KcDeH7gWiAAKSIAACTMgwV6iHuwnVxo5MPQQ	AgADkiAAAkzIMFc	video	9sa3kBjTOtovULIf.mp4	1605704	\N	7178345185	2026-07-26 11:03:21.187079+07	\N
8	AgACAgUAAxkBAAIBNmplhwhR2eJLkYSlt1PV_suGUwyrAALDEmsbTMgwVzfz1jYftExDAQADAgADeQADPQQ	AQADwxJrG0zIMFd-	photo	\N	159370	\N	7178345185	2026-07-26 11:03:21.197076+07	\N
9	BAACAgUAAxkBAAIBOGplhwh86Zxpn50XyGu-wxZB-vmpAAKTIAACTMgwVx9kWmfy9fhYPQQ	AgADkyAAAkzIMFc	video	Beloved wife .mp4	2656875	\N	7178345185	2026-07-26 11:03:21.228754+07	\N
10	BAACAgUAAxkBAAIBOmplhwhnobdEBtZ9AAEOuS0JzhkNAgAClSAAAkzIMFe5G5_DWVDeBT0E	AgADlSAAAkzIMFc	video	b_oNSS7FQHGSRrLw.mp4	1643702	\N	7178345185	2026-07-26 11:03:21.230755+07	\N
11	BAACAgUAAxkBAAIBOWplhwgIV9ZqdRYbfYRalEvr4ATCAAKUIAACTMgwVyMHVh_7KFM7PQQ	AgADlCAAAkzIMFc	video	Nhà không có ai, thích tự chơi một mình,....mp4	2748238	\N	7178345185	2026-07-26 11:03:21.231763+07	\N
12	BAACAgUAAxkBAAIBPGplhwgbeCAujvDC8AVQPyXFqQABdAACliAAAkzIMFd2QKfQv_w_Tj0E	AgADliAAAkzIMFc	video	would you behave if I wore this- .mp4	2043196	\N	7178345185	2026-07-26 11:03:21.23376+07	\N
13	BAACAgUAAxkBAAIBPWplhwiZaPqs_wu-6QosZfyu2LNaAAKaIAACTMgwV6lQRcjdLiuvPQQ	AgADmiAAAkzIMFc	video	Mọi người ngủ chưa ạ- Ở đâu mưa thì nói ....mp4	4155337	\N	7178345185	2026-07-26 11:03:21.235755+07	\N
14	BAACAgUAAxkBAAIBP2plhwimj0R6a7bfQh0KXLMbtIipAAKZIAACTMgwV-5nVV4nNmrQPQQ	AgADmSAAAkzIMFc	video	0GuM6fw3rP2usg-d.mp4	1858787	\N	7178345185	2026-07-26 11:03:21.236757+07	\N
15	BAACAgUAAxkBAAIBO2plhwjKK0zdVFs8auZaze-Ax1pGAAKXIAACTMgwV6FBRPaYVeB1PQQ	AgADlyAAAkzIMFc	video	Having big milkers is such a blessing.mp4	3018774	\N	7178345185	2026-07-26 11:03:21.238905+07	\N
16	BAACAgUAAxkBAAIBPmplhwjbG6vdDYDGhEJS1YGTpMh5AAKYIAACTMgwV2rpGTjJbQxgPQQ	AgADmCAAAkzIMFc	video	h5H78wrxSiRoqfxr.mp4	1595451	\N	7178345185	2026-07-26 11:03:21.245903+07	\N
17	AgACAgUAAxkBAAIBQGplhwo7z_rAZFnVxnA3_JoggHZ9AALGEmsbTMgwVxEuB3vKniKcAQADAgADeQADPQQ	AQADxhJrG0zIMFd-	photo	\N	90339	\N	7178345185	2026-07-26 11:03:21.769856+07	\N
18	BAACAgUAAxkBAAIBQmplhwr0BhcY7xsCZmDBceBdE0BPAAKcIAACTMgwV80hwZcrhFgaPQQ	AgADnCAAAkzIMFc	video	X2Twitter.com_0yHiwy8AZfM-Mq4q_1280p.mp4	2576105	\N	7178345185	2026-07-26 11:03:22.636447+07	\N
19	BAACAgUAAxkBAAIBQWplhwpgPu0OUl9vxFe0Cku9NBrtAAKbIAACTMgwV69RkgV3ObUvPQQ	AgADmyAAAkzIMFc	video	X2Twitter.com_GRQAcibpZh5qKF-1_1280p.mp4	2172064	\N	7178345185	2026-07-26 11:03:22.636447+07	\N
20	BAACAgUAAxkBAAIBRWplhwpDXgugtbFOspCZSETtjQ73AAKeIAACTMgwV2AwZw8bbaQQPQQ	AgADniAAAkzIMFc	video	Nó phải thế chứ lị .mp4	1268986	\N	7178345185	2026-07-26 11:03:22.638457+07	\N
21	BAACAgUAAxkBAAIBQ2plhwrCQ6tvWQm75WzmNmkoN5p5AAKdIAACTMgwV0QZSVn-Y-NMPQQ	AgADnSAAAkzIMFc	video	X2Twitter.com_Y_w4i4Kd-MqRC8S5_1920p.mp4	1005131	\N	7178345185	2026-07-26 11:03:22.638457+07	\N
22	BAACAgUAAxkBAAIBRGplhwonRcaNhQt1s52m0SS5oM0rAAKgIAACTMgwVwoCTXkZAAG97T0E	AgADoCAAAkzIMFc	video	tutu188588 - 我爱洗澡皮肤好好.mp4	14451750	\N	7178345185	2026-07-26 11:03:22.638457+07	\N
23	AgACAgUAAxkBAAIBRmplhwoBXxy-fjRnCtze9pduw5o-AALFEmsbTMgwV7wwLZKwrmmyAQADAgADeQADPQQ	AQADxRJrG0zIMFd-	photo	\N	207912	\N	7178345185	2026-07-26 11:03:22.638457+07	\N
24	BAACAgUAAxkBAAIBSGplhwr4mU6QAAEaY04i8BWz-RtCNQACoiAAAkzIMFfBnL3Yaz4PCT0E	AgADoiAAAkzIMFc	video	Get recovered from a fever .mp4	6379925	\N	7178345185	2026-07-26 11:03:22.643305+07	\N
25	BAACAgUAAxkBAAIBR2plhwpjSwedyU-xcIis08peBdqCAAKfIAACTMgwV3tg9j4-VH3TPQQ	AgADnyAAAkzIMFc	video	ethereal8202.mp4	4962750	\N	7178345185	2026-07-26 11:03:22.643305+07	\N
26	BAACAgUAAxkBAAIBSWplhwq2mePjY2y5pJkHrTPRgBFZAAKhIAACTMgwVz3I9zmo_gI7PQQ	AgADoSAAAkzIMFc	video	OFyuVfgzTXJQ-Anc.mp4	1039596	\N	7178345185	2026-07-26 11:03:22.643305+07	\N
27	BAACAgUAAxkBAAIBSmplhwp91znUl94ed1hCi1mbz-zeAAKjIAACTMgwV5zk4j_6aWOHPQQ	AgADoyAAAkzIMFc	video	QTrWQgPRECNtiXHj.mp4	3385199	\N	7178345185	2026-07-26 11:03:22.643305+07	\N
33	CAACAgUAAxkBAAIBEGpkqgPs0_E2-8_TWvFEo-eDp5bhAAINDgACvho4ViMZdHOIg9rWPQQ	AgADDQ4AAr4aOFY	sticker	Sticker/Emoji 💇 (noelfhoney)	20788	Emoji: 💇 | Custom ID: None	7178345185	2026-07-26 11:04:11.471666+07	\N
35	CAACAgUAAxkBAAIBDGpkqfoVadeyImojmOseiJHTWI9PAALPEwAChTs4VkZQPnAciW4ZPQQ	AgADzxMAAoU7OFY	sticker	Sticker/Emoji 🤲 (noelfhoney)	35554	Emoji: 🤲 | Custom ID: None	7178345185	2026-07-26 11:04:13.596301+07	\N
36	CAACAgUAAxkBAAIBVmplhz_hbRhF-vYMlmEG5CJK-82NAAJpFAACU_o4Vj0N8mw4HCXBPQQ	AgADaRQAAlP6OFY	sticker	Sticker/Emoji 🤳 (noelfhoney)	22768	Emoji: 🤳 | Custom ID: None	7178345185	2026-07-26 11:04:15.48893+07	\N
37	CAACAgUAAxkBAAIBV2plh0BtZGizZBrifvGfZG2OI2wDAALpDgAC6IE4Vnn51zrlkWJUPQQ	AgAD6Q4AAuiBOFY	sticker	Sticker/Emoji 🤲 (noelfhoney)	6860	Emoji: 🤲 | Custom ID: None	7178345185	2026-07-26 11:04:16.558546+07	\N
38	CAACAgUAAxkBAAIBWGplh0L7KSuQ2I1vvw1AQ8RcX8ASAAJ0EQACY7Q4VhjAjwk0AjhtPQQ	AgADdBEAAmO0OFY	sticker	Sticker/Emoji 🤲 (noelfhoney)	20766	Emoji: 🤲 | Custom ID: None	7178345185	2026-07-26 11:04:17.743527+07	\N
39	CAACAgUAAxkBAAIBWWplh-mUkduWOcap9JbmMyG06536AAJpDgACB7Q4VtYtX2FJEzJNPQQ	AgADaQ4AAge0OFY	sticker	Sticker/Emoji 💇 (noelfhoney)	38038	Emoji: 💇 | Custom ID: None	7178345185	2026-07-26 11:07:05.078087+07	\N
40	CAACAgUAAxkBAAIBWmplh-oFF8MnM-sSqytEspevPzsLAAJcEgACUuU5VhmTTEGRoDENPQQ	AgADXBIAAlLlOVY	sticker	Sticker/Emoji 🧥 (noelfhoney)	22020	Emoji: 🧥 | Custom ID: None	7178345185	2026-07-26 11:07:06.478792+07	\N
28	CAACAgUAAxkBAAIBD2pkqgO3eH7gCbIq1bZKmaXtxNlaAALAEQACW2s4VgXvCJUKCuarPQQ	AgADwBEAAltrOFY	sticker	Sticker/Emoji 💇 (noelfhoney)	23440	Emoji: 💇 | Custom ID: None	7178345185	2026-07-26 11:04:01.684278+07	AgACAgUAAxkDAAIBgmpllG86iGMmBC1yeF-QL8W9KZmtAAIEE2sbTMgwVyB61-G19gotAQADAgADeAADPQQ
29	CAACAgUAAxkBAAIBDmpkqgH-tX_mDUiLJFAF3RXGttqpAAKtEAACRxY5VoiqEjKp7V7fPQQ	AgADrRAAAkcWOVY	sticker	Sticker/Emoji 🔥 (noelfhoney)	28430	Emoji: 🔥 | Custom ID: None	7178345185	2026-07-26 11:04:03.695649+07	AgACAgUAAxkDAAIBgmpllHF_R-xjq4jIjDnpwcfwqGbIAAIFE2sbTMgwV8Xq-0wf8mhXAQADAgADeAADPQQ
31	CAACAgUAAxkBAAIBUWplhzmOsP24jSS5-AoPN-QgqlbmAAKtDgACXMw5Vhp7RbGYgvkjPQQ	AgADrQ4AAlzMOVY	sticker	Sticker/Emoji ✋ (noelfhoney)	15928	Emoji: ✋ | Custom ID: None	7178345185	2026-07-26 11:04:09.080475+07	AgACAgUAAxkDAAIBg2pllHke3F_KLRlx5kYvFPNgO902AAIHE2sbTMgwV9_LkLta-VeYAQADAgADeAADPQQ
32	CAACAgUAAxkBAAIBEWpkqgSw_tzWLoL9uVWAINLdI1I2AAKjEQACsr85Vpotn3vQFlD-PQQ	AgADoxEAArK_OVY	sticker	Sticker/Emoji 👍 (noelfhoney)	37284	Emoji: 👍 | Custom ID: None	7178345185	2026-07-26 11:04:10.313511+07	AgACAgUAAxkDAAIBg2pllH17zQuKVcyNiNptbLOPktArAAIIE2sbTMgwV-WQVee5iWg5AQADAgADeAADPQQ
41	CAACAgUAAxkBAAIBW2plh-3arHcDhyGM5iqfGOsfdzVMAAKODwACxQY4Vppe26oWjv4IPQQ	AgADjg8AAsUGOFY	sticker	Sticker/Emoji 💪 (noelfhoney)	14734	Emoji: 💪 | Custom ID: None	7178345185	2026-07-26 11:07:09.395583+07	AgACAgUAAxkDAAIBl2plmoFISLAq6fXvc6rTbPJlnY3TAAK1HWsbXsoxV0e4yMBAb-KOAQADAgADeAADPQQ
43	CAACAgUAAxkBAAIBXWplh_BUGViQnGrk7jGpPBK9EYKWAAIUFAACnPU4VkEMFTF1YUSfPQQ	AgADFBQAApz1OFY	sticker	Sticker/Emoji 👂 (noelfhoney)	15266	Emoji: 👂 | Custom ID: None	7178345185	2026-07-26 11:07:11.628194+07	AgACAgUAAxkDAAIBmGplmoHnBcRCXO5jQMO_awZ0f3wpAAK2HWsbXsoxV5DrIsUjPfN8AQADAgADeAADPQQ
42	CAACAgUAAxkBAAIBXGplh--nrJnnGUnHqcsY_u4F9KLkAAL6DgACN3g5VmnriHx6RsD4PQQ	AgAD-g4AAjd4OVY	sticker	Sticker/Emoji 💪 (noelfhoney)	32172	Emoji: 💪 | Custom ID: None	7178345185	2026-07-26 11:07:10.644531+07	AgACAgUAAxkDAAIBnGplmosVOzrzK_9mtlNQZeM7YrtZAAK6HWsbXsoxV_wM3omSspsHAQADAgADeAADPQQ
44	CAACAgUAAxkBAAIBXmplh_Bb1x0OgdC6gvVK3FPUyqunAAISEwACIE05VnGQTafYoBd7PQQ	AgADEhMAAiBNOVY	sticker	Sticker/Emoji 🤲 (noelfhoney)	24072	Emoji: 🤲 | Custom ID: None	7178345185	2026-07-26 11:07:12.520848+07	\N
46	CAACAgUAAxkBAAIBYGplh_InqfTgSU5aUYmTnh7ZsQmvAAKwEAACBtk4VudieVIqmxgLPQQ	AgADsBAAAgbZOFY	sticker	Sticker/Emoji 👍 (noelfhoney)	29506	Emoji: 👍 | Custom ID: None	7178345185	2026-07-26 11:07:14.575932+07	\N
45	CAACAgUAAxkBAAIBX2plh_EWhDKyVcCYsFpHgyUYQgx3AAJKEQACE8Q4VhFoj2CeU3AaPQQ	AgADShEAAhPEOFY	sticker	Sticker/Emoji 🥰 (noelfhoney)	23074	Emoji: 🥰 | Custom ID: None	7178345185	2026-07-26 11:07:13.473165+07	\N
47	CAACAgUAAxkBAAIBYWpliAZ4m4EGcwj8Wt9TuGFB5LIxAALXEAACdThAVl0JGpZNL-tCPQQ	AgAD1xAAAnU4QFY	sticker	Sticker/Emoji ✋ (noelfhoney)	16196	Emoji: ✋ | Custom ID: None	7178345185	2026-07-26 11:07:34.09603+07	\N
49	CAACAgUAAxkBAAIBY2pliBShf-6pqeLDmAIK6Dy3olZdAALDFwACn545VvW4u6wRkcAdPQQ	AgADwxcAAp-eOVY	sticker	Sticker/Emoji 🤲 (noelfhoney)	18306	Emoji: 🤲 | Custom ID: None	7178345185	2026-07-26 11:07:48.349489+07	\N
51	CAACAgUAAxkBAAIBZWpliCPJq82AVWoImHipBBH-xqTFAAJ9EwACHhgxVn_D1kyomIjQPQQ	AgADfRMAAh4YMVY	sticker	Sticker/Emoji 😳 (noelfhoney)	21738	Emoji: 😳 | Custom ID: None	7178345185	2026-07-26 11:08:02.931103+07	AgACAgUAAxkDAAIBmWplmoUUv1AAAUbqCB_zK0kuiKabSQACtx1rG17KMVchuRp44ks9-AEAAwIAA3gAAz0E
48	CAACAgUAAxkBAAIBYmpliAf0RpWoQIFSLhuhKgas5Hq1AAJKEAACdx5BVpm7weJbK8IEPQQ	AgADShAAAnceQVY	sticker	Sticker/Emoji 🍖 (noelfhoney)	53158	Emoji: 🍖 | Custom ID: None	7178345185	2026-07-26 11:07:35.304645+07	\N
52	CAACAgUAAxkBAAIBZmpliCRMaTYJAROlSAzeeUCrc6AkAAISEAACV4E5Vmf2-msPPD8ePQQ	AgADEhAAAleBOVY	sticker	Sticker/Emoji 🪑 (noelfhoney)	27174	Emoji: 🪑 | Custom ID: None	7178345185	2026-07-26 11:08:04.469698+07	\N
53	CAACAgUAAxkBAAIBZ2pliCvtyrEnuy-rJfZIHrYUxQO_AAIfEQACokUxVhkBxJDjBFXfPQQ	AgADHxEAAqJFMVY	sticker	Sticker/Emoji 💇 (noelfhoney)	37456	Emoji: 💇 | Custom ID: None	7178345185	2026-07-26 11:08:10.709065+07	\N
54	CAACAgUAAxkBAAIBaGpliCx7QLXweCNeoH3q4XPHercPAAJCFAAC2rY5VsET9Y2QiQbrPQQ	AgADQhQAAtq2OVY	sticker	Sticker/Emoji 🤲 (noelfhoney)	17726	Emoji: 🤲 | Custom ID: None	7178345185	2026-07-26 11:08:11.847326+07	\N
55	CAACAgUAAxkBAAIBaWpliC8toUKpHnkee8lViiMia-1AAAKfDQACu0I4Vk0E2UI8zLp5PQQ	AgADnw0AArtCOFY	sticker	Sticker/Emoji 👂 (noelfhoney)	57860	Emoji: 👂 | Custom ID: None	7178345185	2026-07-26 11:08:14.826255+07	\N
57	CAACAgUAAxkBAAIBa2pliDll59p102CixioCo6g6_QHPAAJhDwACMus4VsPW87HjkgljPQQ	AgADYQ8AAjLrOFY	sticker	Sticker/Emoji 💇 (noelfhoney)	50358	Emoji: 💇 | Custom ID: None	7178345185	2026-07-26 11:08:24.973109+07	\N
3	CAACAgUAAxkBAAIBF2pkuzpqOpJDGkZl-ehO8BhAxLSUAAKuFQACH8g5VjQx3LpejEdhPQQ	AgADrhUAAh_IOVY	sticker	Sticker/Emoji ❤ (noelfhoney)	23360	Emoji: ❤ | Custom ID: None	7178345185	2026-07-25 20:33:46.613533+07	AgACAgUAAxkDAAIBgmpllGHLINsiITYi6_q8nw2cA0EJAAICE2sbTMgwVxY_DFWHNCQ9AQADAgADeAADPQQ
30	CAACAgUAAxkBAAIBFmpkuyzIsXuYwG5V18WVQML1geoqAAJ5EwAC8qtAVqJ_l8zNNBoOPQQ	AgADeRMAAvKrQFY	sticker	Sticker/Emoji 🪑 (noelfhoney)	21930	Emoji: 🪑 | Custom ID: None	7178345185	2026-07-26 11:04:07.879672+07	AgACAgUAAxkDAAIBg2pllHeAE-CfAS9eQj-kl_IWUg-wAAIGE2sbTMgwV5IG5Sk1ITDAAQADAgADeAADPQQ
34	CAACAgUAAxkBAAIBDWpkqf27BWZpB41fqZvX9opiRswQAAKRDwACtnNAVkXU-dAQ4RcZPQQ	AgADkQ8AArZzQFY	sticker	Sticker/Emoji ❤ (noelfhoney)	15372	Emoji: ❤ | Custom ID: None	7178345185	2026-07-26 11:04:12.570665+07	AgACAgUAAxkDAAIBlWplmn0mCxpvx3BERjtdP9O4QolUAAK0HWsbXsoxV7snmoRc5cc5AQADAgADeAADPQQ
56	CAACAgUAAxkBAAIBampliDbvRW6j8qLGUFK_HOJT3MAIAAIiEwACWr84VrV8IYcaidZ7PQQ	AgADIhMAAlq_OFY	sticker	Sticker/Emoji 👂 (noelfhoney)	31906	Emoji: 👂 | Custom ID: None	7178345185	2026-07-26 11:08:22.253168+07	AgACAgUAAxkDAAIBmmplmoeXVNMGSGX8ML3HvJtP8bSFAAK4HWsbXsoxV_frbSO9hU5vAQADAgADeAADPQQ
50	CAACAgUAAxkBAAIBZGpliB-XsVNz2DsXyM0k6pvBYh9FAAIPEAACN3k5Vt5FQ1ro0y93PQQ	AgADDxAAAjd5OVY	sticker	Sticker/Emoji ✋ (noelfhoney)	14504	Emoji: ✋ | Custom ID: None	7178345185	2026-07-26 11:07:58.781916+07	AgACAgUAAxkDAAIBm2plmog9uiI-OXbYpummebMoYzFtAAK5HWsbXsoxV32QRNwLdFF0AQADAgADeAADPQQ
\.


--
-- Data for Name: operations; Type: TABLE DATA; Schema: public; Owner: shop_user
--

COPY public.operations (id, user_id, operation_value, operation_time) FROM stdin;
1	7178345185	100000.00	2026-07-20 23:21:01.909022+07
2	7178345185	5000.00	2026-07-22 16:06:57.646392+07
3	6858166279	30000.00	2026-07-22 17:13:46.737637+07
4	6858166279	5000.00	2026-07-22 17:20:48.365185+07
5	6858166279	5000.00	2026-07-22 17:33:45.522204+07
6	7178345185	-10000.00	2026-07-23 20:16:35.649097+07
7	7178345185	20000.00	2026-07-23 20:16:35.651121+07
8	7178345185	-10000.00	2026-07-23 20:16:48.31208+07
9	7178345185	-10000.00	2026-07-23 20:16:51.527405+07
10	7178345185	-10000.00	2026-07-23 20:16:58.812819+07
11	7178345185	-10000.00	2026-07-23 20:17:08.294522+07
12	7178345185	-10000.00	2026-07-23 20:17:10.216022+07
13	7178345185	-10000.00	2026-07-23 20:17:11.774337+07
14	7178345185	20000.00	2026-07-23 20:17:11.775862+07
15	7178345185	-10000.00	2026-07-23 20:17:13.401907+07
16	7178345185	-10000.00	2026-07-23 20:17:14.603926+07
17	7178345185	-10000.00	2026-07-23 20:17:15.854739+07
18	7178345185	100000000.00	2026-07-25 18:16:58.75811+07
19	7178345185	-10000.00	2026-07-25 18:17:07.499985+07
20	7178345185	-10000.00	2026-07-25 18:17:10.509535+07
21	7178345185	-10000.00	2026-07-25 18:17:11.769445+07
22	7178345185	-10000.00	2026-07-25 18:17:12.727388+07
23	7178345185	-10000.00	2026-07-25 18:17:13.586535+07
24	7178345185	-10000.00	2026-07-25 18:17:14.463009+07
25	7178345185	-10000.00	2026-07-25 18:17:15.277434+07
26	7178345185	-10000.00	2026-07-25 18:17:20.811866+07
27	7178345185	-10000.00	2026-07-25 18:17:21.970241+07
28	7178345185	-10000.00	2026-07-25 18:17:22.921064+07
29	7178345185	-10000.00	2026-07-25 18:17:23.713906+07
30	7178345185	-10000.00	2026-07-25 18:17:25.050621+07
31	7178345185	-10000.00	2026-07-25 18:17:25.847027+07
32	7178345185	-10000.00	2026-07-25 18:17:26.56611+07
33	7178345185	-10000.00	2026-07-25 18:17:29.084902+07
34	7178345185	-10000.00	2026-07-25 18:17:30.33435+07
35	7178345185	-10000.00	2026-07-25 18:17:30.524236+07
36	7178345185	-10000.00	2026-07-25 18:17:30.950666+07
37	7178345185	-10000.00	2026-07-25 18:17:31.242487+07
38	7178345185	-10000.00	2026-07-25 18:17:35.19221+07
39	7178345185	-10000.00	2026-07-25 18:17:35.528705+07
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: shop_user
--

COPY public.payments (id, provider, external_id, user_id, amount, currency, status, created_at, updated_at) FROM stdin;
1	payos	1784710940961	7178345185	5000.00	VND	succeeded	2026-07-22 16:02:22.591815+07	2026-07-22 16:06:57.637914+07
4	payos	1784715151741	6858166279	30000.00	VND	succeeded	2026-07-22 17:12:32.580429+07	2026-07-22 17:13:46.731687+07
6	payos	1784715573409	6858166279	5000.00	VND	succeeded	2026-07-22 17:19:34.282794+07	2026-07-22 17:20:48.355306+07
9	payos	1784716411998	6858166279	5000.00	VND	succeeded	2026-07-22 17:33:32.750499+07	2026-07-22 17:33:45.513545+07
2	payos	1784711646335	7178345185	5000.00	VND	failed	2026-07-22 16:14:07.146584+07	2026-07-22 22:43:33.117583+07
3	payos	1784714774184	7178345185	5000.00	VND	failed	2026-07-22 17:06:15.513239+07	2026-07-22 22:43:33.117583+07
5	payos	1784715539446	6858166279	5000.00	VND	failed	2026-07-22 17:19:00.073034+07	2026-07-22 22:43:33.117583+07
7	payos	1784716315216	6858166279	5000.00	VND	failed	2026-07-22 17:31:56.170154+07	2026-07-22 22:43:33.117583+07
8	payos	1784716397062	6858166279	5000.00	VND	failed	2026-07-22 17:33:18.076814+07	2026-07-22 22:43:33.117583+07
10	payos	1784730349737	7178345185	5000.00	VND	failed	2026-07-22 21:25:50.78927+07	2026-07-22 22:43:33.117583+07
11	payos	1784800571269	7178345185	5000.00	VND	failed	2026-07-23 16:56:12.333804+07	2026-07-23 17:32:00.806634+07
12	payos	1784803085665	7178345185	5000.00	VND	failed	2026-07-23 17:38:06.474426+07	2026-07-23 18:12:28.196628+07
13	payos	1784812665116	7178345185	10000.00	VND	failed	2026-07-23 20:17:45.892881+07	2026-07-23 20:48:29.038213+07
\.


--
-- Data for Name: promo_code_usages; Type: TABLE DATA; Schema: public; Owner: shop_user
--

COPY public.promo_code_usages (id, promo_id, user_id, used_at) FROM stdin;
1	1	7178345185	2026-07-20 23:21:01.880346+07
2	2	7178345185	2026-07-25 18:16:58.748372+07
\.


--
-- Data for Name: promo_codes; Type: TABLE DATA; Schema: public; Owner: shop_user
--

COPY public.promo_codes (id, code, discount_type, discount_value, max_uses, current_uses, expires_at, category_id, item_id, is_active, created_at, scope) FROM stdin;
1	123456	balance	100000.00	100	1	\N	\N	\N	t	2026-07-19 22:15:25.714164+07	global
2	12345	balance	100000000.00	1	1	\N	\N	\N	t	2026-07-25 18:16:27.336968+07	global
\.


--
-- Data for Name: referral_earnings; Type: TABLE DATA; Schema: public; Owner: shop_user
--

COPY public.referral_earnings (id, referrer_id, referral_id, amount, original_amount, created_at) FROM stdin;
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: shop_user
--

COPY public.reviews (id, user_id, rating, text, created_at, item_id) FROM stdin;
1	6858166279	5	\N	2026-07-22 17:34:14.127668+07	2
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: shop_user
--

COPY public.roles (id, name, "default", permissions) FROM stdin;
1	USER	t	1
2	ADMIN	f	927
3	OWNER	f	1023
\.


--
-- Data for Name: stock_subscriptions; Type: TABLE DATA; Schema: public; Owner: shop_user
--

COPY public.stock_subscriptions (id, user_id, item_id, created_at) FROM stdin;
3	7178345185	2	2026-07-23 16:55:54.372645+07
\.


--
-- Data for Name: storefront_settings; Type: TABLE DATA; Schema: public; Owner: shop_user
--

COPY public.storefront_settings (id, main_menu_description, shop_description, extra_descriptions) FROM stdin;
1	<b>🚀 CHÀO MỪNG BẠN ĐẾN VỚI PREMIUM ACCOUNT STORE</b>\r\n\r\n<i>Nơi cung cấp tài khoản số, gói Premium và các dịch vụ trực tuyến nhanh chóng, tiện lợi, minh bạch.</i>\r\n\r\n<blockquote>\r\n💎 Sản phẩm đa dạng  \r\n⚡ Giao hàng nhanh chóng  \r\n🛡️ Chính sách bảo hành rõ ràng  \r\n🤝 Hỗ trợ khách hàng tận tâm  \r\n💰 Giá cả cạnh tranh\r\n</blockquote>\r\n\r\n<b>🛒 SẢN PHẨM TẠI SHOP</b>\r\n\r\n✅ Tài khoản Premium theo thời hạn\r\n✅ Gói nâng cấp chính chủ\r\n✅ Tài khoản dùng riêng hoặc dùng chung\r\n✅ Dịch vụ gia hạn tài khoản\r\n✅ Các sản phẩm và dịch vụ số khác\r\n✅ Hỗ trợ tìm sản phẩm theo nhu cầu\r\n\r\n<i>Danh sách sản phẩm, thời hạn sử dụng và mức giá có thể thay đổi theo từng thời điểm. Vui lòng kiểm tra thông tin chi tiết trước khi thanh toán.</i>\r\n\r\n<b>⚡ QUY TRÌNH MUA HÀNG</b>\r\n\r\n<blockquote>\r\n<b>Bước 1:</b> Chọn sản phẩm bạn cần.\r\n\r\n<b>Bước 2:</b> Đọc kỹ mô tả, thời hạn sử dụng và điều kiện bảo hành.\r\n\r\n<b>Bước 3:</b> Thực hiện thanh toán theo hướng dẫn của bot.\r\n\r\n<b>Bước 4:</b> Hệ thống xác nhận giao dịch.\r\n\r\n<b>Bước 5:</b> Nhận sản phẩm hoặc thông tin hướng dẫn sử dụng.\r\n\r\n</blockquote>\r\n\r\n<b>🎁 ƯU ĐIỂM KHI MUA HÀNG TẠI SHOP</b>\r\n\r\n💠 <b>Giao hàng nhanh:</b> Sản phẩm được xử lý tự động hoặc trong thời gian sớm nhất.\r\n\r\n💠 <b>Thông tin minh bạch:</b> Mỗi sản phẩm đều có mô tả, thời hạn và chính sách bảo hành cụ thể.\r\n\r\n💠 <b>Hỗ trợ tận tâm:</b> Shop hỗ trợ kiểm tra và xử lý các vấn đề phát sinh trong phạm vi bảo hành.\r\n\r\n💠 <b>Giá hợp lý:</b> Mức giá được cập nhật thường xuyên để phù hợp với thị trường.\r\n\r\n💠 <b>Bảo mật thông tin:</b> Shop không yêu cầu các thông tin không cần thiết ngoài phạm vi xử lý đơn hàng.\r\n\r\n<b>🛡️ CHÍNH SÁCH BẢO HÀNH</b>\r\n\r\n<blockquote expandable>\r\n✅ Sản phẩm được bảo hành theo đúng thời gian ghi trong phần mô tả.\r\n\r\n✅ Khách hàng cần cung cấp mã đơn hàng hoặc thông tin giao dịch khi yêu cầu hỗ trợ.\r\n\r\n✅ Shop hỗ trợ đổi sản phẩm khi lỗi được xác định thuộc về phía hệ thống hoặc nguồn cung cấp.\r\n\r\n✅ Bảo hành không áp dụng với các trường hợp khách hàng tự ý thay đổi thông tin, chia sẻ tài khoản sai quy định, sử dụng phần mềm bên thứ ba hoặc vi phạm điều khoản của nền tảng.\r\n\r\n✅ Thời gian xử lý bảo hành phụ thuộc vào từng loại sản phẩm và tình trạng thực tế.\r\n\r\n✅ Mỗi sản phẩm có thể có chính sách riêng. Khách hàng nên đọc kỹ trước khi mua.\r\n\r\n</blockquote>\r\n\r\n<b>⚠️ LƯU Ý QUAN TRỌNG</b>\r\n\r\n<blockquote>\r\n• Không chia sẻ tài khoản hoặc thông tin đăng nhập cho người lạ.\r\n\r\n• Không thay đổi mật khẩu, email hoặc thông tin bảo mật khi sản phẩm không cho phép.\r\n\r\n• Không đăng nhập trên quá nhiều thiết bị cùng lúc.\r\n\r\n• Không sử dụng sản phẩm cho các hoạt động vi phạm pháp luật hoặc điều khoản của nền tảng.\r\n\r\n• Hãy quay lại video quá trình nhận và đăng nhập sản phẩm để thuận tiện khi cần hỗ trợ.\r\n\r\n• Chỉ giao dịch thông qua bot và tài khoản hỗ trợ chính thức của shop.\r\n\r\n</blockquote>\r\n\r\n<b>🔐 CAM KẾT TỪ SHOP</b>\r\n\r\n✅ Không bán sai mô tả.\r\n✅ Không tự ý thay đổi đơn hàng.\r\n✅ Không yêu cầu thanh toán ngoài hệ thống khi chưa xác minh.\r\n✅ Không tiết lộ thông tin khách hàng.\r\n✅ Hỗ trợ đúng phạm vi và điều kiện bảo hành.\r\n✅ Ưu tiên trải nghiệm và quyền lợi của khách hàng.\r\n\r\n<b>💳 THANH TOÁN</b>\r\n\r\nShop hỗ trợ các phương thức thanh toán được hiển thị trực tiếp trong bot.\r\n\r\n<tg-spoiler>Hãy kiểm tra kỹ tên người nhận, nội dung chuyển khoản và số tiền trước khi xác nhận thanh toán.</tg-spoiler>\r\n\r\n<b>📦 TRẠNG THÁI ĐƠN HÀNG</b>\r\n\r\nBạn có thể kiểm tra đơn hàng bằng mã giao dịch:\r\n\r\n<code>/orders</code>\r\n\r\nHoặc liên hệ bộ phận hỗ trợ và cung cấp:\r\n\r\n<pre>\r\nMã đơn hàng:\r\nTên sản phẩm:\r\nThời gian thanh toán:\r\nNội dung cần hỗ trợ:\r\n</pre>\r\n\r\n<b>☎️ HỖ TRỢ KHÁCH HÀNG</b>\r\n\r\nKhi gặp vấn đề, vui lòng mô tả rõ tình trạng và gửi kèm ảnh hoặc video để shop kiểm tra nhanh hơn.\r\n\r\n<i>Vui lòng không gửi lặp lại quá nhiều tin nhắn. Yêu cầu của bạn sẽ được xử lý theo thứ tự.</i>\r\n\r\n<b>🎉 CHƯƠNG TRÌNH ƯU ĐÃI</b>\r\n\r\n🎁 Giảm giá cho khách hàng cũ.\r\n🎁 Mã khuyến mãi theo từng sự kiện.\r\n🎁 Ưu đãi khi mua số lượng lớn.\r\n🎁 Quà tặng dành cho khách hàng thân thiết.\r\n🎁 Giá đặc biệt trong các chương trình giới hạn.\r\n\r\n<blockquote>\r\nTheo dõi thông báo từ bot để không bỏ lỡ các chương trình mới nhất.\r\n</blockquote>\r\n\r\n<b>🌟 PHƯƠNG CHÂM HOẠT ĐỘNG</b>\r\n\r\n<i>Uy tín tạo niềm tin — Chất lượng tạo giá trị — Hỗ trợ tạo sự khác biệt.</i>\r\n\r\nShop luôn cố gắng mang đến trải nghiệm mua hàng đơn giản, nhanh chóng và an toàn nhất cho khách hàng.\r\n\r\n<b>❤️ CẢM ƠN BẠN ĐÃ TIN TƯỞNG VÀ ỦNG HỘ SHOP!</b>\r\n\r\n<blockquote>\r\n🚀 Chọn sản phẩm  \r\n💳 Thanh toán  \r\n⚡ Nhận hàng  \r\n🛡️ Hỗ trợ bảo hành\r\n</blockquote>\r\n\r\n<b>👉 Nhấn vào menu bên dưới để bắt đầu mua hàng.</b>\r\n	<b>🚀 CHÀO MỪNG BẠN ĐẾN VỚI PREMIUM ACCOUNT STORE</b>\r\n\r\n<i>Nơi cung cấp tài khoản số, gói Premium và các dịch vụ trực tuyến nhanh chóng, tiện lợi, minh bạch.</i>	{"ngam_xinh": "Chào mừng bạn đến với góc thư giãn! Hãy chọn loại nội dung bạn muốn xem bên dưới:\\r\\nsdak,mhsdj ksjkdfh jklsdhf jksdfh jskdfh jkd fh"}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: shop_user
--

COPY public.users (telegram_id, role_id, balance, referral_id, registration_date, is_blocked, language) FROM stdin;
7178345185	3	99797500.00	\N	2026-07-19 22:08:32.081547+07	f	vi
6858166279	1	12500.00	\N	2026-07-19 22:12:08.589222+07	f	vi
\.


--
-- Name: audit_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shop_user
--

SELECT pg_catalog.setval('public.audit_log_id_seq', 323, true);


--
-- Name: bought_goods_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shop_user
--

SELECT pg_catalog.setval('public.bought_goods_id_seq', 26, true);


--
-- Name: cart_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shop_user
--

SELECT pg_catalog.setval('public.cart_items_id_seq', 2, true);


--
-- Name: categories_new_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shop_user
--

SELECT pg_catalog.setval('public.categories_new_id_seq', 2, true);


--
-- Name: content_pages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shop_user
--

SELECT pg_catalog.setval('public.content_pages_id_seq', 1, true);


--
-- Name: gacha_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shop_user
--

SELECT pg_catalog.setval('public.gacha_items_id_seq', 5, true);


--
-- Name: gacha_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shop_user
--

SELECT pg_catalog.setval('public.gacha_settings_id_seq', 1, true);


--
-- Name: gacha_user_wins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shop_user
--

SELECT pg_catalog.setval('public.gacha_user_wins_id_seq', 31, true);


--
-- Name: goods_new_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shop_user
--

SELECT pg_catalog.setval('public.goods_new_id_seq', 2, true);


--
-- Name: item_values_new_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shop_user
--

SELECT pg_catalog.setval('public.item_values_new_id_seq', 82, true);


--
-- Name: media_capture_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shop_user
--

SELECT pg_catalog.setval('public.media_capture_settings_id_seq', 1, true);


--
-- Name: media_vault_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shop_user
--

SELECT pg_catalog.setval('public.media_vault_id_seq', 58, true);


--
-- Name: operations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shop_user
--

SELECT pg_catalog.setval('public.operations_id_seq', 39, true);


--
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shop_user
--

SELECT pg_catalog.setval('public.payments_id_seq', 13, true);


--
-- Name: promo_code_usages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shop_user
--

SELECT pg_catalog.setval('public.promo_code_usages_id_seq', 2, true);


--
-- Name: promo_codes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shop_user
--

SELECT pg_catalog.setval('public.promo_codes_id_seq', 2, true);


--
-- Name: referral_earnings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shop_user
--

SELECT pg_catalog.setval('public.referral_earnings_id_seq', 1, false);


--
-- Name: reviews_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shop_user
--

SELECT pg_catalog.setval('public.reviews_id_seq', 1, true);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shop_user
--

SELECT pg_catalog.setval('public.roles_id_seq', 3, true);


--
-- Name: stock_subscriptions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shop_user
--

SELECT pg_catalog.setval('public.stock_subscriptions_id_seq', 3, true);


--
-- Name: storefront_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shop_user
--

SELECT pg_catalog.setval('public.storefront_settings_id_seq', 1, false);


--
-- Name: users_telegram_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shop_user
--

SELECT pg_catalog.setval('public.users_telegram_id_seq', 1, false);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--
-- Name: bought_goods bought_goods_pkey; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.bought_goods
    ADD CONSTRAINT bought_goods_pkey PRIMARY KEY (id);


--
-- Name: bought_goods bought_goods_unique_id_key; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.bought_goods
    ADD CONSTRAINT bought_goods_unique_id_key UNIQUE (unique_id);


--
-- Name: cart_items cart_items_pkey; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_pkey PRIMARY KEY (id);


--
-- Name: categories categories_new_name_key; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_new_name_key UNIQUE (name);


--
-- Name: categories categories_new_pkey; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_new_pkey PRIMARY KEY (id);


--
-- Name: content_pages content_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.content_pages
    ADD CONSTRAINT content_pages_pkey PRIMARY KEY (id);


--
-- Name: gacha_items gacha_items_pkey; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.gacha_items
    ADD CONSTRAINT gacha_items_pkey PRIMARY KEY (id);


--
-- Name: gacha_settings gacha_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.gacha_settings
    ADD CONSTRAINT gacha_settings_pkey PRIMARY KEY (id);


--
-- Name: gacha_user_wins gacha_user_wins_pkey; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.gacha_user_wins
    ADD CONSTRAINT gacha_user_wins_pkey PRIMARY KEY (id);


--
-- Name: goods goods_new_name_key; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.goods
    ADD CONSTRAINT goods_new_name_key UNIQUE (name);


--
-- Name: goods goods_new_pkey; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.goods
    ADD CONSTRAINT goods_new_pkey PRIMARY KEY (id);


--
-- Name: item_values item_values_new_pkey; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.item_values
    ADD CONSTRAINT item_values_new_pkey PRIMARY KEY (id);


--
-- Name: media_capture_settings media_capture_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.media_capture_settings
    ADD CONSTRAINT media_capture_settings_pkey PRIMARY KEY (id);


--
-- Name: media_vault media_vault_pkey; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.media_vault
    ADD CONSTRAINT media_vault_pkey PRIMARY KEY (id);


--
-- Name: operations operations_pkey; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.operations
    ADD CONSTRAINT operations_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: promo_code_usages promo_code_usages_pkey; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.promo_code_usages
    ADD CONSTRAINT promo_code_usages_pkey PRIMARY KEY (id);


--
-- Name: promo_codes promo_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.promo_codes
    ADD CONSTRAINT promo_codes_pkey PRIMARY KEY (id);


--
-- Name: referral_earnings referral_earnings_pkey; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.referral_earnings
    ADD CONSTRAINT referral_earnings_pkey PRIMARY KEY (id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: stock_subscriptions stock_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.stock_subscriptions
    ADD CONSTRAINT stock_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: storefront_settings storefront_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.storefront_settings
    ADD CONSTRAINT storefront_settings_pkey PRIMARY KEY (id);


--
-- Name: cart_items uq_cart_item_per_user; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT uq_cart_item_per_user UNIQUE (user_id, item_id);


--
-- Name: item_values uq_item_value_per_item_new; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.item_values
    ADD CONSTRAINT uq_item_value_per_item_new UNIQUE (item_id, value);


--
-- Name: payments uq_payment_provider_ext; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT uq_payment_provider_ext UNIQUE (provider, external_id);


--
-- Name: promo_code_usages uq_promo_usage_per_user; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.promo_code_usages
    ADD CONSTRAINT uq_promo_usage_per_user UNIQUE (promo_id, user_id);


--
-- Name: reviews uq_review_per_user_item; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT uq_review_per_user_item UNIQUE (user_id, item_id);


--
-- Name: stock_subscriptions uq_stock_sub_per_user_item; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.stock_subscriptions
    ADD CONSTRAINT uq_stock_sub_per_user_item UNIQUE (user_id, item_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (telegram_id);


--
-- Name: ix_audit_log_action; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_audit_log_action ON public.audit_log USING btree (action);


--
-- Name: ix_audit_log_timestamp; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_audit_log_timestamp ON public.audit_log USING btree ("timestamp");


--
-- Name: ix_audit_log_user_id; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_audit_log_user_id ON public.audit_log USING btree (user_id);


--
-- Name: ix_bought_goods_buyer_datetime; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_bought_goods_buyer_datetime ON public.bought_goods USING btree (buyer_id, bought_datetime);


--
-- Name: ix_bought_goods_buyer_id; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_bought_goods_buyer_id ON public.bought_goods USING btree (buyer_id);


--
-- Name: ix_bought_goods_datetime; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_bought_goods_datetime ON public.bought_goods USING btree (bought_datetime);


--
-- Name: ix_cart_items_item_id; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_cart_items_item_id ON public.cart_items USING btree (item_id);


--
-- Name: ix_cart_items_user_id; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_cart_items_user_id ON public.cart_items USING btree (user_id);


--
-- Name: ix_content_pages_is_active; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_content_pages_is_active ON public.content_pages USING btree (is_active);


--
-- Name: ix_content_pages_parent_id; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_content_pages_parent_id ON public.content_pages USING btree (parent_id);


--
-- Name: ix_goods_description_trgm; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_goods_description_trgm ON public.goods USING gin (description public.gin_trgm_ops);


--
-- Name: ix_goods_name_trgm; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_goods_name_trgm ON public.goods USING gin (name public.gin_trgm_ops);


--
-- Name: ix_goods_new_category_id; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_goods_new_category_id ON public.goods USING btree (category_id);


--
-- Name: ix_item_values_new_item_id; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_item_values_new_item_id ON public.item_values USING btree (item_id);


--
-- Name: ix_item_values_new_item_inf; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_item_values_new_item_inf ON public.item_values USING btree (item_id, is_infinity);


--
-- Name: ix_media_vault_file_id; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_media_vault_file_id ON public.media_vault USING btree (file_id);


--
-- Name: ix_media_vault_media_type; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_media_vault_media_type ON public.media_vault USING btree (media_type);


--
-- Name: ix_media_vault_uploader_user_id; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_media_vault_uploader_user_id ON public.media_vault USING btree (uploader_user_id);


--
-- Name: ix_operations_time; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_operations_time ON public.operations USING btree (operation_time);


--
-- Name: ix_operations_user_id; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_operations_user_id ON public.operations USING btree (user_id);


--
-- Name: ix_payments_provider; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_payments_provider ON public.payments USING btree (provider);


--
-- Name: ix_payments_status_created; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_payments_status_created ON public.payments USING btree (status, created_at);


--
-- Name: ix_payments_user_id; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_payments_user_id ON public.payments USING btree (user_id);


--
-- Name: ix_promo_codes_code; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE UNIQUE INDEX ix_promo_codes_code ON public.promo_codes USING btree (code);


--
-- Name: ix_promo_codes_is_active; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_promo_codes_is_active ON public.promo_codes USING btree (is_active);


--
-- Name: ix_referral_earnings_referral_created; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_referral_earnings_referral_created ON public.referral_earnings USING btree (referral_id, created_at);


--
-- Name: ix_referral_earnings_referral_id; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_referral_earnings_referral_id ON public.referral_earnings USING btree (referral_id);


--
-- Name: ix_referral_earnings_referrer_created; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_referral_earnings_referrer_created ON public.referral_earnings USING btree (referrer_id, created_at);


--
-- Name: ix_referral_earnings_referrer_id; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_referral_earnings_referrer_id ON public.referral_earnings USING btree (referrer_id);


--
-- Name: ix_reviews_item_id; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_reviews_item_id ON public.reviews USING btree (item_id);


--
-- Name: ix_reviews_user_id; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_reviews_user_id ON public.reviews USING btree (user_id);


--
-- Name: ix_roles_default; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_roles_default ON public.roles USING btree ("default");


--
-- Name: ix_stock_subscriptions_item_id; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_stock_subscriptions_item_id ON public.stock_subscriptions USING btree (item_id);


--
-- Name: ix_stock_subscriptions_user_id; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_stock_subscriptions_user_id ON public.stock_subscriptions USING btree (user_id);


--
-- Name: ix_users_is_blocked; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_users_is_blocked ON public.users USING btree (is_blocked);


--
-- Name: ix_users_referral_id; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_users_referral_id ON public.users USING btree (referral_id);


--
-- Name: ix_users_registration_date; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_users_registration_date ON public.users USING btree (registration_date);


--
-- Name: ix_users_role_id; Type: INDEX; Schema: public; Owner: shop_user
--

CREATE INDEX ix_users_role_id ON public.users USING btree (role_id);


--
-- Name: bought_goods bought_goods_buyer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.bought_goods
    ADD CONSTRAINT bought_goods_buyer_id_fkey FOREIGN KEY (buyer_id) REFERENCES public.users(telegram_id);


--
-- Name: cart_items cart_items_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.goods(id) ON DELETE CASCADE;


--
-- Name: cart_items cart_items_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(telegram_id) ON DELETE CASCADE;


--
-- Name: content_pages content_pages_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.content_pages
    ADD CONSTRAINT content_pages_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.content_pages(id) ON DELETE CASCADE;


--
-- Name: users fk_users_referral_id_users; Type: FK CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_users_referral_id_users FOREIGN KEY (referral_id) REFERENCES public.users(telegram_id) ON DELETE SET NULL;


--
-- Name: users fk_users_role_id_roles; Type: FK CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_users_role_id_roles FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE RESTRICT;


--
-- Name: gacha_items gacha_items_goods_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.gacha_items
    ADD CONSTRAINT gacha_items_goods_id_fkey FOREIGN KEY (goods_id) REFERENCES public.goods(id) ON DELETE SET NULL;


--
-- Name: gacha_user_wins gacha_user_wins_gacha_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.gacha_user_wins
    ADD CONSTRAINT gacha_user_wins_gacha_item_id_fkey FOREIGN KEY (gacha_item_id) REFERENCES public.gacha_items(id) ON DELETE SET NULL;


--
-- Name: gacha_user_wins gacha_user_wins_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.gacha_user_wins
    ADD CONSTRAINT gacha_user_wins_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(telegram_id) ON DELETE CASCADE;


--
-- Name: goods goods_new_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.goods
    ADD CONSTRAINT goods_new_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE;


--
-- Name: item_values item_values_new_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.item_values
    ADD CONSTRAINT item_values_new_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.goods(id) ON DELETE CASCADE;


--
-- Name: operations operations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.operations
    ADD CONSTRAINT operations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(telegram_id) ON DELETE SET NULL;


--
-- Name: payments payments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(telegram_id) ON DELETE SET NULL;


--
-- Name: promo_code_usages promo_code_usages_promo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.promo_code_usages
    ADD CONSTRAINT promo_code_usages_promo_id_fkey FOREIGN KEY (promo_id) REFERENCES public.promo_codes(id) ON DELETE CASCADE;


--
-- Name: promo_code_usages promo_code_usages_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.promo_code_usages
    ADD CONSTRAINT promo_code_usages_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(telegram_id) ON DELETE CASCADE;


--
-- Name: promo_codes promo_codes_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.promo_codes
    ADD CONSTRAINT promo_codes_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE SET NULL;


--
-- Name: promo_codes promo_codes_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.promo_codes
    ADD CONSTRAINT promo_codes_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.goods(id) ON DELETE SET NULL;


--
-- Name: referral_earnings referral_earnings_referral_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.referral_earnings
    ADD CONSTRAINT referral_earnings_referral_id_fkey FOREIGN KEY (referral_id) REFERENCES public.users(telegram_id) ON DELETE CASCADE;


--
-- Name: referral_earnings referral_earnings_referrer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.referral_earnings
    ADD CONSTRAINT referral_earnings_referrer_id_fkey FOREIGN KEY (referrer_id) REFERENCES public.users(telegram_id) ON DELETE CASCADE;


--
-- Name: reviews reviews_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.goods(id) ON DELETE CASCADE;


--
-- Name: reviews reviews_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(telegram_id) ON DELETE CASCADE;


--
-- Name: stock_subscriptions stock_subscriptions_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.stock_subscriptions
    ADD CONSTRAINT stock_subscriptions_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.goods(id) ON DELETE CASCADE;


--
-- Name: stock_subscriptions stock_subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.stock_subscriptions
    ADD CONSTRAINT stock_subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(telegram_id) ON DELETE CASCADE;


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- PostgreSQL database dump complete
--

\unrestrict K04ZNgnKPUJ8YOVO76TeM47Xe6GYV4OlpokDdDjNwcuqVbpWVqjX56chczIfcx9

