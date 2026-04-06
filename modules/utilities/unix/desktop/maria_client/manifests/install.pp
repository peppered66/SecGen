class maria_client::install{
  package {'mariadb-client':
  ensure => installed,
}
}
