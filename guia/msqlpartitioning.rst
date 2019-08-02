Configurar MySQL partitioning
=================================

https://www.zabbix.org/wiki/Docs/howto/mysql_partitioning

https://www.zabbix.org/wiki/Docs/howto/mysql_partition

Voy a utilizar el primer link y en especifico "external script" se debe tener instalado perl y perl-DateTime

Partitioning with an external script
An external script can be used instead of stored procedures. While it should be scheduled outside the database, it usually will be simpler and easier to debug. It is suggested to add a daily cron job. The script supports creating new partitions and deleting the old ones.

Note: Before adding the script as a cron job, the desired storage period and partition type for each table must be set in the script itself. Setting keep_history to 0 will only keep one, currently active partition.
Note: The script currently assumes usage Zabbix before version 2.2 (without a way to enable specific housekeeper controls). For zabbix starting from 2.2 comment 5 lines as suggested inside the script.

Para visualizar las particiones de una tabla.::

	SHOW CREATE TABLE history;

Para eliminar las particiones de una tabla.::

	ALTER TABLE history REMOVE PARTITIONING;

Para eliminar una particion de una tabla y su contenido.::

	ALTER TABLE `history` TRUNCATE PARTITION p2017_04_29;

	# Cuando hace el select ya no hay informacion
  
	select * from history where clock <= 1493511092;

	mysql> show variables like 'have_partitioning';
	+-------------------+-------+
	| Variable_name     | Value |
	+-------------------+-------+
	| have_partitioning | YES   |
	+-------------------+-------+
	1 row in set (0.00 sec)

	mysql> show variables like 'have_symlink';
	+---------------+-------+
	| Variable_name | Value |
	+---------------+-------+
	| have_symlink  | YES   |
	+---------------+-------+
	1 row in set (0.00 sec)

Yuo can enable on my.cnf

	mysql> SELECT FROM_UNIXTIME(MIN(clock)) FROM `history_uint`;
	+---------------------------+
	| FROM_UNIXTIME(MIN(clock)) |
	+---------------------------+
	| 2017-04-29 20:11:20       |
	+---------------------------+
	1 row in set (0.05 sec)

	ALTER TABLE housekeeper ENGINE = BLACKHOLE;

	mysql>  SHOW GLOBAL VARIABLES LIKE 'event_scheduler';
	+-----------------+-------+
	| Variable_name   | Value |
	+-----------------+-------+
	| event_scheduler | OFF   |
	+-----------------+-------+
	1 row in set (0.00 sec)

	mysql>  SET GLOBAL event_scheduler = ON;
	Query OK, 0 rows affected (0.00 sec)

You should also put a line in the 'my.cnf' file like "event_scheduler=ON" in case of reboot.

	ALTER TABLE `history_log` DROP PRIMARY KEY, ADD INDEX `history_log_0` (`id`);
	ALTER TABLE `history_log` DROP KEY `history_log_2`;
	ALTER TABLE `history_text` DROP PRIMARY KEY, ADD INDEX `history_text_0` (`id`);
	ALTER TABLE `history_text` DROP KEY `history_text_2`;

	mysql> SELECT FROM_UNIXTIME(MIN(clock)) FROM `history`;
	+---------------------------+
	| FROM_UNIXTIME(MIN(clock)) |
	+---------------------------+
	| 2017-04-29 20:11:19       |
	+---------------------------+
	1 row in set (0.02 sec)

For Day

	ALTER TABLE `history` PARTITION BY RANGE ( clock)
	(PARTITION p2017_04_28 VALUES LESS THAN (UNIX_TIMESTAMP("2017-04-29 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_04_29 VALUES LESS THAN (UNIX_TIMESTAMP("2017-04-30 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_30 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-01 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_01 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-02 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_02 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-03 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_03 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-04 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_04 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-05 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_05 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-06 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_06 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-07 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_07 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-08 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_08 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-09 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_09 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-10 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_10 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-11 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_11 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-12 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_12 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-13 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_13 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-14 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_14 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-15 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_15 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-16 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_16 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-17 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_17 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-18 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_18 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-19 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_19 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-20 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_20 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-21 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_21 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-22 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_22 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-23 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_23 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-24 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_24 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-25 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_25 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-26 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_26 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-27 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_27 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-28 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_28 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-29 00:00:00")) ENGINE = InnoDB,
	PARTITION p2017_05_29 VALUES LESS THAN (UNIX_TIMESTAMP("2017-05-30 00:00:00")) ENGINE = InnoDB);

For Month

	ALTER TABLE `trends_uint` PARTITION BY RANGE ( clock)
	(PARTITION p2010_10 VALUES LESS THAN (UNIX_TIMESTAMP("2010-11-01 00:00:00")) ENGINE = InnoDB,
	 PARTITION p2010_11 VALUES LESS THAN (UNIX_TIMESTAMP("2010-12-01 00:00:00")) ENGINE = InnoDB,
	 PARTITION p2010_12 VALUES LESS THAN (UNIX_TIMESTAMP("2011-01-01 00:00:00")) ENGINE = InnoDB,
	...
	 PARTITION p2011_08 VALUES LESS THAN (UNIX_TIMESTAMP("2011-09-01 00:00:00")) ENGINE = InnoDB,
	 PARTITION p2011_09 VALUES LESS THAN (UNIX_TIMESTAMP("2011-10-01 00:00:00")) ENGINE = InnoDB,
	 PARTITION p2011_10 VALUES LESS THAN (UNIX_TIMESTAMP("2011-11-01 00:00:00")) ENGINE = InnoDB,
	 PARTITION p2011_11 VALUES LESS THAN (UNIX_TIMESTAMP("2011-12-01 00:00:00")) ENGINE = InnoDB,
	 PARTITION p2011_12 VALUES LESS THAN (UNIX_TIMESTAMP("2012-01-01 00:00:00")) ENGINE = InnoDB);

If you want to do manual

	ALTER TABLE `history_uint` ADD PARTITION p2011_10_23 VALUES LESS THAN (UNIX_TIMESTAMP("2011-10-24 00:00:00")) ENGINE = InnoDB;
	ALTER TABLE `trends_uint` DROP PARTITION p2011_06;

Create a crontab tha call the next script.

Create the next script in /usr/local/bin with exectute permision.::

	#!/usr/bin/perl

	use strict;
	use Data::Dumper;
	use DBI;
	use Sys::Syslog qw(:standard :macros);
	use DateTime;
	use POSIX qw(strftime);

	openlog("mysql_zbx_part", "ndelay,pid", LOG_LOCAL0);

	my $db_schema = 'zabbix';
	my $dsn = 'DBI:mysql:'.$db_schema.':mysql_socket=/var/lib/mysql/mysql.sock';
	my $db_user_name = 'zbx_srv';
	my $db_password = '<password here>';
	my $tables = {	'history' => { 'period' => 'day', 'keep_history' => '30'},
			'history_log' => { 'period' => 'day', 'keep_history' => '30'},
			'history_str' => { 'period' => 'day', 'keep_history' => '30'},
			'history_text' => { 'period' => 'day', 'keep_history' => '30'},
			'history_uint' => { 'period' => 'day', 'keep_history' => '30'},
			'trends' => { 'period' => 'month', 'keep_history' => '2'},
			'trends_uint' => { 'period' => 'month', 'keep_history' => '2'},

	# comment next 5 lines if you partition zabbix database starting from 2.2
	# they usually used for zabbix database before 2.2

			'acknowledges' => { 'period' => 'month', 'keep_history' => '23'},
			'alerts' => { 'period' => 'month', 'keep_history' => '6'},
			'auditlog' => { 'period' => 'month', 'keep_history' => '24'},
			'events' => { 'period' => 'month', 'keep_history' => '12'},
			'service_alarms' => { 'period' => 'month', 'keep_history' => '6'},
			};
	my $amount_partitions = 10;

	my $curr_tz = 'Europe/London';

	my $part_tables;

	my $dbh = DBI->connect($dsn, $db_user_name, $db_password);

	unless ( check_have_partition() ) {
		print "Your installation of MySQL does not support table partitioning.\n";
		syslog(LOG_CRIT, 'Your installation of MySQL does not support table partitioning.');
		exit 1;
	}

	my $sth = $dbh->prepare(qq{SELECT table_name, partition_name, lower(partition_method) as partition_method,
						rtrim(ltrim(partition_expression)) as partition_expression,
						partition_description, table_rows
					FROM information_schema.partitions
					WHERE partition_name IS NOT NULL AND table_schema = ?});
	$sth->execute($db_schema);

	while (my $row =  $sth->fetchrow_hashref()) {
		$part_tables->{$row->{'table_name'}}->{$row->{'partition_name'}} = $row;
	}

	$sth->finish();

	foreach my $key (sort keys %{$tables}) {
		unless (defined($part_tables->{$key})) {
			syslog(LOG_ERR, 'Partitioning for "'.$key.'" is not found! The table might be not partitioned.');
			next;
		}

		create_next_partition($key, $part_tables->{$key}, $tables->{$key}->{'period'});
		remove_old_partitions($key, $part_tables->{$key}, $tables->{$key}->{'period'}, $tables->{$key}->{'keep_history'})
	}

	delete_old_data();

	$dbh->disconnect();

	sub check_have_partition {
		my $result = 0;
	# MySQL 5.5
		my $sth = $dbh->prepare(qq{SELECT variable_value FROM information_schema.global_variables WHERE variable_name = 'have_partitioning'});
	# MySQL 5.6
		#my $sth = $dbh->prepare(qq{SELECT plugin_status FROM information_schema.plugins WHERE plugin_name = 'partition'});

		$sth->execute();

		my $row = $sth->fetchrow_array();

		$sth->finish();

	# MySQL 5.5
		return 1 if $row eq 'YES';
	# MySQL 5.6
		#return 1 if $row eq 'ACTIVE';
	}

	sub create_next_partition {
		my $table_name = shift;
		my $table_part = shift;
		my $period = shift;

		for (my $curr_part = 0; $curr_part < $amount_partitions; $curr_part++) {
			my $next_name = name_next_part($tables->{$table_name}->{'period'}, $curr_part);
			my $found = 0;

			foreach my $partition (sort keys %{$table_part}) {
				if ($next_name eq $partition) {
					syslog(LOG_INFO, "Next partition for $table_name table has already been created. It is $next_name");
					$found = 1;
				}
			}

			if ( $found == 0 ) {
				syslog(LOG_INFO, "Creating a partition for $table_name table ($next_name)");
				my $query = 'ALTER TABLE '."$db_schema.$table_name".' ADD PARTITION (PARTITION '.$next_name.
							' VALUES less than (UNIX_TIMESTAMP("'.date_next_part($tables->{$table_name}->{'period'}, $curr_part).'") div 1))';
				syslog(LOG_DEBUG, $query);
				$dbh->do($query);
			}
		}
	}

	sub remove_old_partitions {
		my $table_name = shift;
		my $table_part = shift;
		my $period = shift;
		my $keep_history = shift;

		my $curr_date = DateTime->now;
		$curr_date->set_time_zone( $curr_tz );

		if ( $period eq 'day' ) {
			$curr_date->add(days => -$keep_history);
			$curr_date->add(hours => -$curr_date->strftime('%H'));
			$curr_date->add(minutes => -$curr_date->strftime('%M'));
			$curr_date->add(seconds => -$curr_date->strftime('%S'));
		}
		elsif ( $period eq 'week' ) {
		}
		elsif ( $period eq 'month' ) {
			$curr_date->add(months => -$keep_history);

			$curr_date->add(days => -$curr_date->strftime('%d')+1);
			$curr_date->add(hours => -$curr_date->strftime('%H'));
			$curr_date->add(minutes => -$curr_date->strftime('%M'));
			$curr_date->add(seconds => -$curr_date->strftime('%S'));
		}

		foreach my $partition (sort keys %{$table_part}) {
			if ($table_part->{$partition}->{'partition_description'} <= $curr_date->epoch) {
				syslog(LOG_INFO, "Removing old $partition partition from $table_name table");

				my $query = "ALTER TABLE $db_schema.$table_name DROP PARTITION $partition";

				syslog(LOG_DEBUG, $query);
				$dbh->do($query);
			}
		}
	}

	sub name_next_part {
		my $period = shift;
		my $curr_part = shift;

		my $name_template;

		my $curr_date = DateTime->now;
		$curr_date->set_time_zone( $curr_tz );

		if ( $period eq 'day' ) {
			my $curr_date = $curr_date->truncate( to => 'day' );
			$curr_date->add(days => 1 + $curr_part);

			$name_template = $curr_date->strftime('p%Y_%m_%d');
		}
		elsif ($period eq 'week') {
			my $curr_date = $curr_date->truncate( to => 'week' );
			$curr_date->add(days => 7 * $curr_part);

			$name_template = $curr_date->strftime('p%Y_%m_w%W');
		}
		elsif ($period eq 'month') {
			my $curr_date = $curr_date->truncate( to => 'month' );
			$curr_date->add(months => 1 + $curr_part);

			$name_template = $curr_date->strftime('p%Y_%m');
		}

		return $name_template;
	}

	sub date_next_part {
		my $period = shift;
		my $curr_part = shift;

		my $period_date;

		my $curr_date = DateTime->now;
		$curr_date->set_time_zone( $curr_tz );

		if ( $period eq 'day' ) {
			my $curr_date = $curr_date->truncate( to => 'day' );
			$curr_date->add(days => 2 + $curr_part);
			$period_date = $curr_date->strftime('%Y-%m-%d');
		}
		elsif ($period eq 'week') {
			my $curr_date = $curr_date->truncate( to => 'week' );
			$curr_date->add(days => 7 * $curr_part + 1);
			$period_date = $curr_date->strftime('%Y-%m-%d');
		}
		elsif ($period eq 'month') {
			my $curr_date = $curr_date->truncate( to => 'month' );
			$curr_date->add(months => 2 + $curr_part);

			$period_date = $curr_date->strftime('%Y-%m-%d');
		}

		return $period_date;
	}

	sub delete_old_data {
		$dbh->do("DELETE FROM sessions WHERE lastaccess < UNIX_TIMESTAMP(NOW() - INTERVAL 1 MONTH)");
		$dbh->do("TRUNCATE housekeeper");
		$dbh->do("DELETE FROM auditlog_details WHERE NOT EXISTS (SELECT NULL FROM auditlog WHERE auditlog.auditid = auditlog_details.auditid)");
	}


