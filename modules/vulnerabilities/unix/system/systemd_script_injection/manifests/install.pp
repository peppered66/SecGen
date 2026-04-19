class systemd_script_injection::install {

 $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
 $leaked_filenames = $secgen_parameters['leaked_filenames']
 $strings_to_leak = $secgen_parameters['strings_to_leak']


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

   #Clean way to provision a file containing a flag compared to previous ERB template files
  ::secgen_functions::leak_files { 'systemd-script-injection-flag-leak':
    storage_directory => '/root',
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => 'root',
    mode              => '0600',
    leaked_from       => 'systemd-script-injection-flag-leak',
  }
}


