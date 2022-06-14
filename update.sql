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
('watch_pid', '');
ALTER TABLE `admin_settings`
  ADD PRIMARY KEY (`type`);
COMMIT;
