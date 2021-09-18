CREATE TABLE IF NOT EXISTS pm_page (
    site_id TEXT
    ,url TEXT
    ,alias TEXT
    ,page_type TEXT NOT NULL
    ,template_file TEXT
    ,plugin_id TEXT
    ,redirect_url TEXT

    ,CONSTRAINT pm_page_url_pkey PRIMARY KEY (site_id, url)
);

CREATE UNIQUE INDEX IF NOT EXISTS pm_page_alias_idx ON pm_page (site_id, alias);

CREATE TABLE IF NOT EXISTS pm_data (
    site_id TEXT
    ,data_id TEXT
    ,data JSONB

    ,CONSTRAINT pm_data_site_id_data_file_pkey PRIMARY KEY (site_id, data_id)
);
