CREATE TABLE IF NOT EXISTS pm_site (
    site_id UUID
    ,name TEXT

    ,CONSTRAINT pm_site_site_id_pkey PRIMARY KEY (site_id)
);

CREATE TABLE IF NOT EXISTS pm_page (
    site_id UUID
    ,url TEXT
    ,template_file TEXT
    ,plugin TEXT
    ,redirect_url TEXT

    ,CONSTRAINT pm_site_id_url_pkey PRIMARY KEY (site_id, url)
);

CREATE TABLE IF NOT EXISTS pm_data (
    site_id UUID
    ,data_file TEXT
    ,data JSONB

    ,CONSTRAINT pm_data_site_id_key_pkey PRIMARY KEY (site_id, data_file)
);

CREATE TABLE IF NOT EXISTS pm_user (
    user_id UUID
    ,username TEXT
    ,email TEXT
    ,password_hash TEXT

    ,CONSTRAINT pm_user_user_id_pkey PRIMARY KEY (user_id)
    ,CONSTRAINT pm_user_username_key UNIQUE (username)
    ,CONSTRAINT pm_user_email_key UNIQUE (email)
);

CREATE TABLE IF NOT EXISTS pm_user_site_roles (
    user_id UUID
    ,site_id UUID
    ,roles TEXT[]

    ,CONSTRAINT pm_user_role_user_id_site_id_pkey PRIMARY KEY (user_id, site_id)
);

CREATE TABLE IF NOT EXISTS pm_role (
    site_id UUID
    ,role TEXT
    ,authz_attributes JSONB

    ,CONSTRAINT pm_role_site_id_role_pkey PRIMARY KEY (site_id, role)
);

CREATE TABLE IF NOT EXISTS pm_user_authz (
    site_id UUID
    ,user_id UUID
    ,authz_attributes JSONB

    ,CONSTRAINT pm_user_authz_site_id_user_id_pkey PRIMARY KEY (site_id, user_id)
);

CREATE TABLE IF NOT EXISTS pm_i18n (
    site_id UUID
    ,langcode TEXT
    ,description TEXT

    ,CONSTRAINT pm_i18n_site_id_langcode PRIMARY KEY (site_id, langcode)
);

-- the problem with all this flexibility is that now there are tons of database lookups for every request

-- lookup pm_site to check which site, lookup langcode to check if there is any langcode in the prefix,

-- I could potentially remove the langcode check by hardcoding it to a fixed list: no one can start a URL with a langcode.
