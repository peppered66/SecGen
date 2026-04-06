class systemd_script_injection::service{

  #command to start timer and run service on loop
 exec {'start_timer':
    command => '/bin/systemctl enable --now script_timer.timer',
    require => [
        File['/etc/systemd/system/script_timer.service'],
        File['/etc/systemd/system/script_timer.timer'],
        Exec['systemd-daemon-reload'],
    ],
    unless => '/bin/systemctl is-enabled script_timer.timer',
 }
}
