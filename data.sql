DELETE FROM pm_template_data;

DELETE FROM pm_page;

INSERT INTO pm_page
    (page_id, data, data_groups)
VALUES
    ('landing', '{"a":"a","b":"b"}', '["1", "2", "3"]')
;

INSERT INTO pm_data_group
    (name, data)
VALUES
    ('1', '{"c":"c"}')
    ,('2', '{"d":"d"}')
    ,('3', '{"e":"e"}')
;
