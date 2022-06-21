DROP TABLE IF EXISTS `reg_users`;
CREATE TABLE `reg_users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `date_registered` int(11) NOT NULL,
  `verify_key` mediumtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_login` int(11) DEFAULT NULL,
  `member_group_id` int(11) NOT NULL,
  `verified` int(11) NOT NULL DEFAULT 0,
  `credits` float NOT NULL DEFAULT 0,
  `notes` mediumtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` tinyint(2) NOT NULL DEFAULT 1,
  `default_lang` mediumtext COLLATE utf8_unicode_ci NOT NULL,
  `reseller_dns` text COLLATE utf8_unicode_ci NOT NULL,
  `owner_id` int(11) NOT NULL DEFAULT 0,
  `override_packages` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `google_2fa_sec` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `dark_mode` int(1) NOT NULL DEFAULT 0,
  `sidebar` int(1) NOT NULL DEFAULT 0,
  `expanded_sidebar` int(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
INSERT INTO `reg_users` (`id`, `username`, `password`, `email`, `ip`, `date_registered`, `verify_key`, `last_login`, `member_group_id`, `verified`, `credits`, `notes`, `status`, `default_lang`, `reseller_dns`, `owner_id`, `override_packages`, `google_2fa_sec`, `dark_mode`, `sidebar`, `expanded_sidebar`) VALUES
(1, 'adminn', 'kkkk', 'EMAIL', NULL, 0, NULL, NULL, 1, 1, 0, NULL, 1, 'fr', '', 0, NULL, '', 0, 1, 1);
ALTER TABLE `reg_users`
  ADD PRIMARY KEY (`id`),
  ADD KEY `member_group_id` (`member_group_id`),
  ADD KEY `username` (`username`),
  ADD KEY `password` (`password`);
ALTER TABLE `reg_users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
COMMIT;
DROP TABLE IF EXISTS `admin_settings`;
CREATE TABLE `admin_settings` (
  `type` varchar(128) NOT NULL DEFAULT '',
  `value` varchar(4096) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
INSERT INTO `admin_settings` (`type`, `value`) VALUES
('active_mannuals', '1'),
('auto_refresh', '1'),
('cc_time', '1655207282'),
('geolite2_version', '1'),
('panel_version', '1'),
('reseller_can_isplock', '1'),
('reseller_reset_isplock', '1'),
('reseller_reset_stb', '1'),
('show_tickets', '1'),
('stats_pid', ''),
('tmdb_pid', ''),
('watch_pid', ''),
('ip_logout', '1'),
('reseller_restrictions', '1'),
('change_own_dns', '1'),
('change_own_email', '1'),
('change_own_password', '1'),
('ip_logout', '1'),
('change_own_lang', '1'),
('reseller_view_info', '1'),
('active_apps', '1'),
('reseller_mag_to_m3u', '1'),
('release_parser', 'python2');
ALTER TABLE `admin_settings`
  ADD PRIMARY KEY (`type`);
COMMIT;
ALTER TABLE settings ADD PRIMARY KEY(id);
-- update panel locale
UPDATE settings SET default_locale = 'fr_FR.utf8' WHERE settings.id = 1;
-- disable empty user agent
UPDATE settings SET disallow_empty_user_agents = '1' WHERE settings.id = 1;
UPDATE settings SET hash_lb = '1' WHERE settings.id = 1;
UPDATE admin_settings SET value = '1' WHERE admin_settings.type = 'order_streams';
UPDATE settings SET audio_restart_loss = '1' WHERE settings.id = 1;
UPDATE settings SET county_override_1st = '1' WHERE settings.id = 1;
UPDATE settings SET disallow_2nd_ip_con = '1' WHERE settings.id = 1;
UPDATE settings SET enable_isp_lock = '1' WHERE settings.id = 1;
UPDATE settings SET vod_bitrate_plus = '300' WHERE settings.id = 1;
UPDATE settings SET vod_limit_at = '10' WHERE settings.id = 1;
UPDATE settings SET block_svp = '1' WHERE settings.id = 1;
UPDATE settings SET priority_backup = '1' WHERE settings.id = 1;
UPDATE settings SET mag_security = '1' WHERE settings.id = 1;
UPDATE settings SET stb_change_pass = '1' WHERE settings.id = 1;
UPDATE settings SET stalker_lock_images = '1' WHERE settings.id = 1;
UPDATE settings SET allowed_stb_types = '["MAG200","MAG245","MAG245D","MAG250","MAG254","MAG255","MAG256","MAG257","MAG260","MAG270","MAG275","MAG322","MAG322w1","MAG322w2","MAG323","MAG324","MAG324C","MAG324w2","MAG325","MAG349","MAG350","MAG351","MAG352","MAG420","MAG420w1","MAG420w2","MAG422","MAG422A","MAG422Aw1","MAG424","MAG424w1","MAG424w2","MAG424w3","MAG424A","MAG424Aw3","MAG425","MAG425A","MAG520","MAG520W1","MAG520W2","MAG520W3","MAG520A","MAG520Aw3","MAG522","MAG522w1","MAG522w3","MAG524","MAG524W3","AuraHD","AuraHD0","AuraHD1","AuraHD2","AuraHD3","AuraHD4","AuraHD5","AuraHD6","AuraHD7","AuraHD8","AuraHD9","WR320","IM2100","IM2100w1","IM2100V","IM2100VI","IM2101","IM2101V","IM2101VI","IM2101VO","IM2101w2","IM2102","IM4410","IM4410w3","IM4411","IM4411w1","IM4412","IM4414","IM4414w1","IP_STB_HD",]' WHERE settings.id = 1;
UPDATE settings SET allowed_stb_types_rec = '1' WHERE settings.id = 1;
UPDATE settings SET allowed_stb_types_for_local_recording = '["MAG200","MAG245","MAG245D","MAG250","MAG254","MAG255","MAG256","MAG257","MAG260","MAG270","MAG275","MAG322","MAG322w1","MAG322w2","MAG323","MAG324","MAG324C","MAG324w2","MAG325","MAG349","MAG350","MAG351","MAG352","MAG420","MAG420w1","MAG420w2","MAG422","MAG422A","MAG422Aw1","MAG424","MAG424w1","MAG424w2","MAG424w3","MAG424A","MAG424Aw3","MAG425","MAG425A","MAG520","MAG520W1","MAG520W2","MAG520W3","MAG520A","MAG520Aw3","MAG522","MAG522w1","MAG522w3","MAG524","MAG524W3","AuraHD","AuraHD0","AuraHD1","AuraHD2","AuraHD3","AuraHD4","AuraHD5","AuraHD6","AuraHD7","AuraHD8","AuraHD9","WR320","IM2100","IM2100w1","IM2100V","IM2100VI","IM2101","IM2101V","IM2101VI","IM2101VO","IM2101w2","IM2102","IM4410","IM4410w3","IM4411","IM4411w1","IM4412","IM4414","IM4414w1","IP_STB_HD",]' WHERE settings.id = 1;
INSERT INTO admin_settings (type, value) VALUES ('clear_log_auto', '1');
INSERT INTO admin_settings (type, value) VALUES ('clear_log_check', '$(date +"%s")');
INSERT INTO admin_settings (type, value) VALUES ('clear_log_tables', '["flushActivity","flushActivitynow","flushPanelogs","flushLoginlogs","flushLogins","flushMagclaims","flushStlogs","flushClientlogs","flushEvents","flushMaglogs"]');
TRUNCATE user_activity;
TRUNCATE user_activity_now;
TRUNCATE panel_logs;
TRUNCATE login_logs;
TRUNCATE login_users;
TRUNCATE mag_claims;
TRUNCATE stream_logs;
TRUNCATE client_logs;
TRUNCATE mag_logs;
TRUNCATE mag_events;
