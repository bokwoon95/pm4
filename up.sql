-- url splitter -> domain, subdomain, langcode, path

-- oodle-of-doodles.blogiverse.io/blog/what-im-up-to
-- domain=blogiverse.io subdomain=oodles-of-doodles langcode= path=/blog/what-im-up-to

CREATE TABLE IF NOT EXIST pm_site (
    site_id UUID
    ,domain TEXT
    ,subdomain TEXT

    ,CONSTRAINT pm_site_site_id_pkey PRIMARY KEY (site_id)
    ,CONSTRAINT pm_site_domain_subdomain_key UNIQUE (domain, subdomain)
);

CREATE TABLE IF NOT EXISTS pm_page (
    site_id UUID
    ,url_path TEXT
    ,template_file TEXT
    ,plugin TEXT
    ,redirect_url TEXT

    ,CONSTRAINT pm_site_id_url_path_pkey PRIMARY KEY (site_id, url_path)
);

CREATE TABLE IF NOT EXISTS pm_template_data (
    site_id UUID
    ,langcode TEXT
    ,data_file TEXT
    ,data JSONB

    ,CONSTRAINT pm_data_site_id_data_file_langcode_pkey PRIMARY KEY (site_id, langcode, data_file)
);

CREATE TABLE IF NOT EXISTS pm_user (
    user_id UUID
    ,username TEXT
    ,email TEXT
    ,name TEXT
    ,password_hash TEXT

    ,CONSTRAINT pm_user_user_id_pkey PRIMARY KEY (user_id)
    ,CONSTRAINT pm_user_username_key UNIQUE (username)
    ,CONSTRAINT pm_user_email_key UNIQUE (email)
);

CREATE TABLE IF NOT EXISTS pm_user_authz (
    site_id UUID
    ,user_id UUID
    ,roles TEXT[]
    ,authz_attributes JSONB
    ,role_authz_attributes JSONB -- trigger recalculation when pm_user_authz.roles or pm_role.authz_attributes is changed

    ,CONSTRAINT pm_user_authz_user_id_site_id_pkey PRIMARY KEY (site_id, user_id)
);

-- trigger recalculation when pm_user_authz.roles is changed
-- sqlite only, because both postgres and mysql support indexing arrays
CREATE TABLE IF NOT EXIST pm_user_authz_roles_tblidx (
    site_id UUID
    ,user_id UUID
    ,role TEXT

    ,CONSTRAINT pmx_user_role_site_id_user_id_role PRIMARY KEY (site_id, user_id, role)
);

CREATE TABLE IF NOT EXISTS pm_role (
    site_id UUID
    ,role TEXT
    ,authz_attributes JSONB

    ,CONSTRAINT pm_role_site_id_role_pkey PRIMARY KEY (site_id, role)
);

CREATE TABLE IF NOT EXISTS pm_session (
    session_hash BYTEA
    ,site_id UUID
    ,user_id UUID
    ,data JSONB

    ,CONSTRAINT pm_session_session_hash_pkey PRIMARY KEY (session_hash)
);

-- the problem with all this flexibility is that now there are tons of database lookups for every request

-- lookup pm_site to check which site, lookup langcode to check if there is any langcode in the prefix,
