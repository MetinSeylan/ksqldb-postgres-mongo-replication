CREATE STREAM color_stream WITH (
    kafka_topic = 'ecommerce.public.color',
    value_format = 'avro'
);

CREATE STREAM variant_stream WITH (
    kafka_topic = 'ecommerce.public.variant',
    value_format = 'avro'
);

CREATE TABLE VARIANT_TABLE AS
    SELECT variant_stream.id,
           as_value(variant_stream.id) as id,
           latest_by_offset(variant_stream.name) AS name,
           latest_by_offset(variant_stream.product_id) AS product_id,
           latest_by_offset(variant_stream.color_id) AS color_id,
           latest_by_offset(variant_stream.created_at) AS created_at,
           latest_by_offset(variant_stream.updated_at) AS updated_at,
           STRUCT(
                   id := latest_by_offset(color_stream.id),
                   name := latest_by_offset(color_stream.name),
                   created_at := latest_by_offset(color_stream.created_at),
                   updated_at := latest_by_offset(color_stream.updated_at)
           ) as color
    FROM variant_stream
    LEFT JOIN color_stream WITHIN 365 DAYS ON variant_stream.color_id = color_stream.id
    GROUP BY variant_stream.id
    EMIT CHANGES;

CREATE STREAM VARIANT_TABLE_STREAM WITH (
    kafka_topic = 'VARIANT_TABLE',
    value_format = 'avro',
    partitions = 1
);

CREATE STREAM VARIANT_TABLE_STREAM_DISTINCT AS
    SELECT * FROM VARIANT_TABLE_STREAM
    PARTITION BY id;

CREATE STREAM product_stream WITH (
    kafka_topic = 'ecommerce.public.product',
    value_format = 'avro'
);


CREATE TABLE PRODUCT_TABLE AS
    SELECT product_stream.id,
           as_value(product_stream.id) as id,
           latest_by_offset(product_stream.title) AS title,
           latest_by_offset(product_stream.text) AS text,
           latest_by_offset(product_stream.created_at) AS created_at,
           latest_by_offset(product_stream.updated_at) AS updated_at,
           COLLECT_SET(variant.id) as variants
    FROM product_stream
    LEFT JOIN VARIANT_TABLE_STREAM_DISTINCT variant WITHIN 365 DAYS ON variant.product_id = product_stream.id
    GROUP BY product_stream.id
    EMIT CHANGES;
