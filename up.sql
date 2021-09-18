CREATE TABLE IF NOT EXISTS pm_page (
    url TEXT
    ,site_id TEXT
    ,page_type TEXT NOT NULL
    ,template_file TEXT
    ,plugin_id TEXT
    ,redirect_url TEXT

    ,CONSTRAINT pm_page_url_pkey PRIMARY KEY (url, site_id)
);

CREATE TABLE IF NOT EXISTS pm_template_data (
    data_file TEXT
    ,site_id TEXT
    ,data JSONB

    ,CONSTRAINT pm_template_data_data_path_site_id_pkey PRIMARY KEY (data_path, site_id)
);
