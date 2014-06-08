CREATE DATABASE `backendkit` /*!40100 DEFAULT CHARACTER SET latin1 */$$

CREATE TABLE `bek_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `verification_token` varchar(32) NOT NULL,
  `date_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `date_last_login` timestamp NULL DEFAULT NULL,
  `date_last_failed_login` timestamp NULL DEFAULT NULL,
  `date_last_password_reset` timestamp NULL DEFAULT NULL,
  `num_failed_logins` int(11) DEFAULT NULL COMMENT 'A failed login attempt increments num_failed_logins.\\n\\nIf num_failed_logins > 2, then 5 seconds must elapse between date_last_failed_login and the next attempt.\\n\\nA successful login resets num_failed_logins to 0.\\n',
  `email_verified` int(11) DEFAULT '0',
  `auth_token` varchar(45) DEFAULT NULL,
  `extra` text,
  PRIMARY KEY (`id`,`email`),
  UNIQUE KEY `email_UNIQUE` (`email`),
  KEY `auth_token` (`auth_token`)
) ENGINE=MyISAM AUTO_INCREMENT=1030 DEFAULT CHARSET=latin1$$

