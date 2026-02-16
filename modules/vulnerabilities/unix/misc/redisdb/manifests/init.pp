class redisdb {

 $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
 $strings_to_leak = $secgen_parameters['strings_to_leak']
 $leaked_filenames = $secgen_parameters['leaked_filenames']

 $redistext1 = "A random string."
 $redistext2 = $strings_to_leak[0]  
 
 $redisfilename1 = $leaked_filenames[0]
 $redisfilename2 = $leaked_filenames[1]

 #Installs redis package
  package { 'redis-server':
    ensure => installed,
  }
  #Ensures redis tools are installed prior to commands being ran (should be done via package download)
  package { 'redis-tools':
    ensure => installed,
  }

  #Creates a service for our redis install
  service { 'redis-server':
    ensure => running,
    enable => true,
    require => Package['redis-server'],
  }

 #Replaces original config file for misconfiguration
  file { '/etc/redis/redis.conf':
    ensure  => file,
    source  => 'puppet:///modules/redisdb/redis.conf',
    owner   => 'redis',
    group   => 'redis',
    mode    => '0640',
    require => Package['redis-server'],
    notify  => Service['redis-server'],
  }
  
 #Creates directory for provisioned files to be stored
  file { '/opt/redis-files':
  ensure => directory,
  owner  => 'root',
  group  => 'root',
  mode   => '0755',
  }

 #Stores file1 on disk
  file { '/opt/redis-files/file1.txt':
  ensure  => file,
  content  => template('redisdb/redistext1.txt.erb'),
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  require => File['/opt/redis-files'],
 }

 #Stores file2 on disk
  file { '/opt/redis-files/file2.txt':
  ensure  => file,
  content  => template('redisdb/redistext2.txt.erb'),
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  require => File['/opt/redis-files'],
 }

 #Runs redis command to store file1 in database
  exec { 'load_file1_into_redis':
command => "/bin/sh -c 'redis-cli SET ${redisfilename1} \"\$(cat /opt/redis-files/file1.txt)\"'",
  path    => ['/usr/bin', '/bin'],
  require => [
    Package['redis-tools'],
    File['/opt/redis-files/file1.txt'],
    Service['redis-server'],
  ],
unless  => "/usr/bin/redis-cli EXISTS ${redisfilename1} | /bin/grep -q '^1\$'",
 }
 #Runs redis command to store file2 in database
  exec { 'load_file2_into_redis':
command => "/bin/sh -c 'redis-cli SET ${redisfilename2} \"\$(cat /opt/redis-files/file2.txt)\"'",
  path    => ['/usr/bin', '/bin'],
  require => [
    Package['redis-tools'],
    File['/opt/redis-files/file2.txt'],
    Service['redis-server'],
  ],
unless  => "/usr/bin/redis-cli EXISTS ${redisfilename2} | /bin/grep -q '^1\$'",
 }
 }
