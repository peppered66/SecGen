class systemd_script_injection::install {

 file {'/opt/script':
  ensure => directory,
  owner  => 'root',
  group  => 'root',
  mode   => '0755',
 }

#script ran by root
 file {'/opt/script/script.sh':
 ensure => file, 
 content => template('systemd_script_injection/script.sh.erb'),
 owner => 'root', 
 group => 'root',
 mode => '0777', # the vuln everybody can write to it
 }

 #service to run script
 file {'/etc/systemd/system/script_timer.service':
 ensure => file, 
 content => template('systemd_script_injection/script_timer.service.erb'),
 owner => 'root', 
 group => 'root',
 mode => '0644', 
 }

 #timer to to run script on a loop
 file {'/etc/systemd/system/script_timer.timer':
 ensure => file, 
 content => template('systemd_script_injection/script_timer.timer.erb'),
 owner => 'root', 
 group => 'root',
 mode => '0644', 
 }
 
 #command to reload systemd when new services are added
 exec { 'systemd-daemon-reload':
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
 }

}
