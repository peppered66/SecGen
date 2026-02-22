class redis_tools::install{
  package { 'redis-tools':
    ensure => installed,
  }
}