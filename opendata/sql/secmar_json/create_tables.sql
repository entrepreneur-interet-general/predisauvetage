DROP TABLE IF EXISTS snosan_json;
CREATE TABLE snosan_json (
  id SERIAL PRIMARY KEY,
  data jsonb
);

CREATE INDEX ON snosan_json((data ->> 'id'::text) text_ops);
CREATE INDEX ON snosan_json((data ->> 'version'::text) text_ops);
CREATE INDEX ON snosan_json((data ->> 'chrono'::text) text_ops);


DROP TABLE IF EXISTS snosan_json_unique;
CREATE TABLE snosan_json_unique (data jsonb);

CREATE INDEX ON snosan_json_unique((data ->> 'version'::text) text_ops);
CREATE INDEX ON snosan_json_unique(((data -> 'identification') ->> 'operativeEvent'::text) text_ops);
CREATE UNIQUE INDEX ON snosan_json_unique((data ->> 'id'::text) text_ops);
CREATE UNIQUE INDEX ON snosan_json_unique((data ->> 'chrono'::text) text_ops);

-- Run this in psql to load data from a file containing JSON lines
-- COPY snosan_json (data) FROM '/tmp/data.json' csv quote e'\x01' delimiter e'\x02';
