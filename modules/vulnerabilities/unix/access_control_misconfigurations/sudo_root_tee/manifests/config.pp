#Module structure inspired from: https://github.com/cliffe/SecGen/tree/master/modules/vulnerabilities/unix/access_control_misconfigurations/sudo_root_awk
class sudo_root_tee::config {

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $username = $secgen_parameters['username']
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']

  #Creates user via secgen parameter for username, creates home directory and shell path
  user { $username:
    ensure     => present,
    managehome => true,
    home       => "/home/${username}",
    shell      => '/bin/bash',
  }
  
  class { 'sudo':
    config_file_replace => false,
  }

  #Creating vulnerable sudo rule to allow provisioned user to run tee as sudo
  sudo::conf { "user_${username}_sudo_tee":
    ensure  => present,
    content => "${username} ALL=(root) NOPASSWD: /usr/bin/tee *",
  }

  # Allow all users to run sudo -l without a password
  sudo::conf { "user_${username}_sudo_list":
    ensure  => present,
    content => "${username} ALL=(root) NOPASSWD: /usr/bin/sudo -l",
  }

 #Clean way to provision a file containing a flag compared to previous ERB template files
  ::secgen_functions::leak_files { 'sudo-root-tee-flag-leak':
    storage_directory => '/root',
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => 'root',
    mode              => '0600',
    leaked_from       => 'sudo-root-tee-flag-leak',
  }
}
