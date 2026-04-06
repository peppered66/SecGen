class ssh_permit_empty_passwords::config {


 #Ensures SSH uses password authentication (settings we change)
  file_line { 'sshd_password_authentication':
    ensure => present,
    path   => '/etc/ssh/sshd_config',
    match  => '^\s*#?\s*PasswordAuthentication\s+',
    line   => 'PasswordAuthentication yes',
  }
  #Ensures SSH allows empty passwords
  file_line { 'sshd_permit_empty_passwords':
    ensure => present,
    path   => '/etc/ssh/sshd_config',
    match  => '^\s*#?\s*PermitEmptyPasswords\s+',
    line   => 'PermitEmptyPasswords yes',
  }
  #Ensures SSH uses pam
  file_line { 'sshd_use_pam':
    ensure => present,
    path   => '/etc/ssh/sshd_config',
    match  => '^\s*#?\s*UsePAM\s+',
    line   => 'UsePAM yes',
  }

  #Restarts ssh service via subscribe parameter, after changes are made to ssh config.
  service { 'ssh':
    ensure    => running,
    enable    => true,
    subscribe => [
      File_line['sshd_password_authentication'],
      File_line['sshd_permit_empty_passwords'],
      File_line['sshd_use_pam'],
    ],
  }



}
