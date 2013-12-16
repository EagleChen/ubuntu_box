$packages = ['vim', 'zsh', 'git-core', 'curl']
$jdk_file = 'jdk-6u45-linux-x64.bin'
$jdk_dir  = 'jdk1.6.0_45'
$configs  = '.gemrc .gitconfig .tmux.conf .zshrc spfvim/.vimrc*'
$user     = 'vagrant'

include apt

apt::ppa {'ppa:git-core/ppa':}

exec { 'apt-get update':
  command => 'apt-get update && touch /var/.apt_updated1',
  path    => '/bin:/usr/bin',
  returns => [0, 100],  # add 100 here due to the bad network
  creates => '/var/.apt_updated1',
  before  => Apt::Ppa['ppa:git-core/ppa'],
}

package { $packages:
  ensure  => present,
  require => Apt::Ppa['ppa:git-core/ppa'],
}

exec { 'install java 6':
  command => "chmod +x ${jdk_file} && ./${jdk_file} && \
              mv ${jdk_dir} /usr/lib",
  path    => '/bin:/usr/bin',
  cwd     => '/vagrant/files/',
  creates => "/usr/lib/${jdk_dir}/bin/java",
}

file { 'set up java':
  ensure  => file,
  path    => '/etc/zsh/zshenv',
  mode    => '+r',
  content => template('/vagrant/files/zshenv.erb'),
  require => [Exec['install java 6'], Exec['install oh_my_zsh']]
}

exec { 'install oh_my_zsh':
  command => "git clone https://github.com/robbyrussell/oh-my-zsh.git /home/${user}/.oh-my-zsh",
  path    => '/bin:/usr/bin',
  require => Package[$packages],
  user    => $user,
  creates => "/home/${user}/.oh-my-zsh/oh-my-zsh.sh",
}

exec { 'install spfvim':
  command     => 'curl https://raw.github.com/EagleChen/configs/master/spfvim/bootstrap.sh -L | sh',
  path        => '/bin:/usr/bin',
  require     => Package[$packages],
  environment => ["HOME=/home/${user}"],
  user        => $user,
  creates     => "/home/${user}/.spf13-vim-3/bootstrap.sh",
}

exec { 'prepare configs':
  command => "git clone https://github.com/EagleChen/configs && \
              cd /tmp/configs && cp ${configs} /home/${user}",
  path    => '/bin:/usr/bin',
  cwd     => '/tmp',
  creates => '/tmp/configs',
  require => [Exec['install oh_my_zsh'], Exec['install spfvim']],
}

user { 'vagrant':
  ensure  => present,
  shell   => '/usr/bin/zsh'
}

notify { 'vim update':
  message => 'please run "vim +BundleInstall! +BundleClean +q" manually',
  require => Exec['prepare configs']
}
