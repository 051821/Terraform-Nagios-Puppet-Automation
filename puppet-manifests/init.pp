# Apache on Linux (Ubuntu Puppet Master)
node 'puppetmaster.example.com' {

  package { 'apache2':
    ensure => installed,
  }

  service { 'apache2':
    ensure  => running,
    enable  => true,
    require => Package['apache2'],
  }

  file { '/var/www/html/index.html':
    ensure  => file,
    content => "<h1>Puppet Managed Apache Server</h1>",
    require => Package['apache2'],
  }

}

# Windows Agent Configuration
node 'win-agent.example.com' {

  # 1. Create directory
  file { 'C:/puppet_test':
    ensure => directory,
  }

  # 2. Create a sample file
  file { 'C:/puppet_test/readme.txt':
    ensure  => file,
    content => "This file is created by Puppet on Windows!",
    require => File['C:/puppet_test'],
  }

  # 3. OPTIONAL — Install Notepad++ (real Windows installation test)
  package { 'Notepad++':
    ensure          => installed,
    source          => 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.6.4/npp.8.6.4.Installer.x64.exe',
    install_options => ['/S'],  
    provider        => 'windows',
  }

  notify { 'Windows agent configuration loaded':
    message => 'Windows changes applied successfully!',
  }
}


