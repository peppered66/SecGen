 class redisdb::config {
 
 #Creates a service for our redis install
  service { 'redis-server':
    ensure => running,
    enable => true,
    require => Package['redis-server'],
  }
 }