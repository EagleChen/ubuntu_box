include apt

apt::ppa {'ppa:webupd8team/java':}

exec { 'apt-get update 1':
  command => "/usr/bin/apt-get update && \
              /usr/bin/touch /var/.apt_updated1",
  before  => Apt::Ppa['ppa:webupd8team/java'],
  creates => '/var/.apt_updated1'
}

exec { 'apt-get update 2':
  command => "/usr/bin/apt-get update && \
              /usr/bin/touch /var/.apt_updated2",
  require => [ Apt::Ppa['ppa:webupd8team/java']],
  creates => '/var/.apt_updated2'
}

package { 'vim-nox':
  ensure  => present,
  require => Exec['apt-get update 2']
}

package { 'git-core':
  ensure  => present,
  require => Exec['apt-get update 2']
}

package { 'oracle-java6-installer':
  ensure  => instaled,
  require => [Exec['apt-get update 2'], Exec['accept_license']]
}

exec { 'accept_license':
  command   => "echo debconf shared/accepted-oracle-license-v1-1 select true | \
                sudo debconf-set-selections && echo debconf \
                shared/accepted-oracle-license-v1-1 seen true | \
                sudo debconf-set-selections",
  cwd       => '/home/vagrant',
  user      => 'vagrant',
  path      => '/usr/bin/:/bin/',
  logoutput => true,
}
