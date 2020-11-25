 CREATE TABLE migrate_version (
    repository_id varchar(64),
    repository_path text,
    version integer
);

GRANT ALL PRIVILEGES ON DATABASE woincapi TO postgres;