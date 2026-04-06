class mariadb::service{

 #Creates a service for our maria install
  service { 'mariadb':
    ensure  => running,
    enable  => true,
    require => Package['mariadb-server'],
  }
}