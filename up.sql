CREATE TABLE IF NOT EXISTS pm_page (
    url TEXT
    ,alias TEXT
    ,template_file TEXT
    ,plugin_id TEXT
    ,redirect_url TEXT

    ,CONSTRAINT pm_page_url_pkey PRIMARY KEY (url)
    ,CONSTRAINT pm_page_alias_key UNIQUE (alias)
);

CREATE TABLE IF NOT EXISTS pm_data (
    data_id TEXT
    ,data JSONB

    ,CONSTRAINT pm_data_data_id_pkey PRIMARY KEY (data_id)
);
