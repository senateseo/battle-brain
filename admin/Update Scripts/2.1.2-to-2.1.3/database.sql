UPDATE `tbl_settings` SET `message` = '2.1.3' WHERE `tbl_settings`.`type` = 'system_version';
INSERT INTO tbl_web_settings (`type`, `message`) SELECT * FROM (SELECT 'toggle_web_home_settings', '1') AS tmp WHERE NOT EXISTS (SELECT type FROM tbl_web_settings WHERE type  ='toggle_web_home_settings') LIMIT 1;
INSERT INTO tbl_settings (`type`, `message`) SELECT * FROM (SELECT 'notification_title', 'Congratulations !') AS tmp WHERE NOT EXISTS (SELECT type FROM tbl_settings WHERE type  ='notification_title') LIMIT 1;
INSERT INTO tbl_settings (`type`, `message`) SELECT * FROM (SELECT 'notification_body', 'You have unlocked new badge.') AS tmp WHERE NOT EXISTS (SELECT type FROM tbl_settings WHERE type  ='notification_body') LIMIT 1;
INSERT INTO tbl_settings (`type`, `message`) SELECT * FROM (SELECT 'daily_ads_visibility', '0') AS tmp WHERE NOT EXISTS (SELECT type FROM tbl_settings WHERE type  ='daily_ads_visibility') LIMIT 1;
INSERT INTO tbl_settings (`type`, `message`) SELECT * FROM (SELECT 'daily_ads_coins', '5') AS tmp WHERE NOT EXISTS (SELECT type FROM tbl_settings WHERE type  ='daily_ads_coins') LIMIT 1;
INSERT INTO tbl_settings (`type`, `message`) SELECT * FROM (SELECT 'daily_ads_counter', '1') AS tmp WHERE NOT EXISTS (SELECT type FROM tbl_settings WHERE type  ='daily_ads_counter') LIMIT 1;
ALTER TABLE tbl_users ADD daily_ads_counter INT NOT NULL DEFAULT '0' COMMENT 'Daily ads counter' AFTER remove_ads, ADD daily_ads_date DATE NOT NULL DEFAULT '2023-10-19' COMMENT 'Daily ads date' AFTER daily_ads_counter;
