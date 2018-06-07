-- Copyright (c) 2016-2018  Timescale, Inc. All Rights Reserved.
--
-- This file is licensed under the Timescale License,
-- see LICENSE-TIMESCALE at the top of the tsl directory.


-- ===================================================================
-- create fake fdw to create server and user mapping
-- ===================================================================

\c :TEST_DBNAME :ROLE_SUPERUSER

CREATE FUNCTION _timescaledb_internal.test_remote_connection()
RETURNS void
AS :TSL_MODULE_PATHNAME, 'tsl_test_remote_connection'
LANGUAGE C STRICT;

CREATE FUNCTION _timescaledb_internal.test_remote_async()
RETURNS void
AS :TSL_MODULE_PATHNAME, 'tsl_test_remote_async'
LANGUAGE C STRICT;

-- ===================================================================
-- create tables
-- ===================================================================

CREATE SCHEMA "S 1";
CREATE TABLE "S 1"."T 1" (
    "C 1" int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 timestamptz,
    c5 timestamp,
    c6 varchar(10),
    c7 char(10),
    CONSTRAINT t1_pkey PRIMARY KEY ("C 1")
);

ANALYZE "S 1"."T 1";

INSERT INTO "S 1"."T 1"
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           '1970-01-01'::timestamptz + ((id % 100) || ' days')::interval,
           '1970-01-01'::timestamp + ((id % 100) || ' days')::interval,
           id % 10,
           id % 10
    FROM generate_series(1, 1000) id;

-- ===================================================================
-- run tests
-- ===================================================================

SELECT _timescaledb_internal.test_remote_connection();
SELECT _timescaledb_internal.test_remote_async();

SELECT 'End Of Test';