create table color
(
    id         serial constraint "PK_d15e531d60a550fbf23e1832343" primary key,
    name       varchar                 not null,
    created_at timestamp default now() not null,
    updated_at timestamp default now() not null
);

create table product
(
    id         serial constraint "PK_bebc9158e480b949565b4dc7a82" primary key,
    title      varchar                 not null,
    text       text                    not null,
    created_at timestamp default now() not null,
    updated_at timestamp default now() not null
);

create table variant
(
    id          serial constraint "PK_f8043a8a34fa021a727a4718470" primary key,
    name        varchar                 not null,
    created_at  timestamp default now() not null,
    updated_at  timestamp default now() not null,
    product_id integer constraint "FK_cb0df5c8d79ac0ea08a87119673" references product,
    color_id   integer constraint "REL_2ec2686909b2474e646f4b6bf7" unique constraint "FK_2ec2686909b2474e646f4b6bf7d" references color
);

