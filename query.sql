EXPLAIN ANALYZE
WITH RECURSIVE tbl (data, n) AS (
    (SELECT data, 0 FROM pm_data_group ORDER BY name LIMIT 1)
    UNION ALL
    (SELECT
        tmp.data || tbl.data
        ,tbl.n + 1
    FROM
        tbl
        CROSS JOIN LATERAL (
            SELECT data
            FROM pm_data_group
            ORDER BY NAME
            LIMIT 1
            OFFSET tbl.n
        ) AS tmp
    )
)
SELECT * from tbl;
