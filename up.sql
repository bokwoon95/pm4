CREATE TABLE IF NOT EXISTS pm_page (
    page_id TEXT
    ,url TEXT
    ,data JSONB NOT NULL DEFAULT '{}'
    ,data_groups JSONB NOT NULL DEFAULT '[]'

    ,CONSTRAINT pm_page_page_id_pkey PRIMARY KEY (page_id)
    ,CONSTRAINT pm_page_page_url_key UNIQUE (url)
);

CREATE TABLE IF NOT EXISTS pm_data_group (
    name TEXT
    ,data JSONB NOT NULL DEFAULT '{}'

    ,CONSTRAINT pm_data_group_name PRIMARY KEY (name)
);
