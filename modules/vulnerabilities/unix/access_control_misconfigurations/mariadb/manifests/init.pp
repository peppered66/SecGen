class mariadb {

   #$secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
   #$strings_to_leak=$secgen_parameters['strings_to_leak']

  $mariatext1 = "A random string."
  $mariatext2 = "Needs secgen integration (strings_to_leak)"

  #Installs maria package
   package { 'mariadb-server':
    ensure => installed,
   }

 #Creates a service for our maria install
  service { 'mariadb':
    ensure  => running,
    enable  => true,
    require => Package['mariadb-server'],
  }

 #Replaces original config file for misconfiguration
  file { '/etc/mysql/mariadb.conf.d/50-server.cnf':
  ensure  => file,
  source  => 'puppet:///modules/mariadb/50-server.cnf',
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  require => Package['mariadb-server'],
  notify  => Service['mariadb'],
  }

 #Creates directory to store files
  file { '/opt/mariadb-files':
  ensure => directory,
  mode   => '0755',
  }

 #Stores the first file on the system
  file { '/opt/mariadb-files/mariatext1.txt':
  ensure  => file,
  content  => template('mariadb/mariatext1.txt.erb'),
  mode    => '0644',
  require => File['/opt/mariadb-files'],
  }

 #Stores the second file on the system
  file { '/opt/mariadb-files/mariatext2.txt':
  ensure  => file,
  content  => template('mariadb/mariatext2.txt.erb'),
  mode    => '0644',
  require => File['/opt/mariadb-files'],
  }

 #Runs maria command to create the database and table within service
 exec { 'create_database_and_table':
  command => '/usr/bin/mysql -u root -e "
    CREATE DATABASE IF NOT EXISTS database;
    USE database;
    CREATE TABLE IF NOT EXISTS files (
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(50),
      content TEXT
    );
  "',
  path    => ['/usr/bin', '/bin'],
  require => Service['mariadb'],
 }

 #Runs maria command to insert the first file into the database
 exec { 'insert_mariatext1_into_maria':
  command => "/bin/sh -c '/usr/bin/mysql -u root database -e \"INSERT INTO files (name, content) VALUES (\\\"mariatext1\\\", \\\"$(cat /opt/mariadb-files/mariatext1.txt)\\\");\"'",
  path    => ['/usr/bin', '/bin'],
  require => [
    Exec['create_database_and_table'],
    File['/opt/mariadb-files/mariatext1.txt'],
    Service['mariadb'],
  ],
  unless  => "/usr/bin/mysql -u root database -N -s -e \"SELECT 1 FROM files WHERE name='mariatext1' LIMIT 1;\" | /bin/grep -q 1",
 }

  #Runs maria command to insert the second file into the database
  exec { 'insert_mariatext2_into_maria':
  command => "/bin/sh -c '/usr/bin/mysql -u root database -e \"INSERT INTO files (name, content) VALUES (\\\"mariatext2\\\", \\\"$(cat /opt/mariadb-files/mariatext2.txt)\\\");\"'",
  path    => ['/usr/bin', '/bin'],
  require => [
    Exec['create_database_and_table'],
    File['/opt/mariadb-files/mariatext2.txt'],
    Service['mariadb'],
  ],
  unless  => "/usr/bin/mysql -u root database -N -s -e \"SELECT 1 FROM files WHERE name='mariatext2' LIMIT 1;\" | /bin/grep -q 1",
 }

  #Runs maria command to add MYSQL anonymous user to database with elevated privilege
 exec { 'allow_anonymous_remote_login':
  command => '/usr/bin/mysql -u root -e "CREATE USER IF NOT EXISTS \'\'@\'%\' IDENTIFIED BY \'\'; GRANT ALL PRIVILEGES ON *.* TO \'\'@\'%\' WITH GRANT OPTION; FLUSH PRIVILEGES;"',
  path    => ['/usr/bin', '/bin'],
  require => Service['mariadb'],
 }
}
