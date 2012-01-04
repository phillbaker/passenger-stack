package :build_essential do
  description 'Build tools'
  
  apt 'build-essential' do
    pre :install, 'apt-get update'
  end
  
  optional :apt_essential
end

package :apt_utils do
  description 'Apt configuration tools to configure packages before apt installation. (E.g. postfix.)'
  
  apt 'debconf-utils'
  
  verify do
    has_executable 'debconf-set-selections'
  end
  
end

package :apt_essential do
  #Other potential tools:
  #curl vim libc6-dev zlib1g-dev php5-cli python gettext python-setuptools proftpd
  apt %w(sudo ssh vim iptables screen gcc make wget) 
  
  banner = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'assets', 'etc', 'banner'))
  #the ':sudo => true option is bogus on transfer, and in general scp doesn't do that: http://superuser.com/questions/138893/scp-to-remote-server-with-sudo/367192#367192
  transfer banner, '/tmp/banner' do
    post :install, 'mv /tmp/banner /etc/'
  end
  
  ssh = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'assets', 'etc', 'ssh', 'sshd_config'))
  transfer ssh, '/tmp/sshd_config' do
    post :install, 'mv /tmp/sshd_config /etc/ssh/'
    post :install, 'service ssh restart' #restart ssh
  end
  
  iptables = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'assets', 'etc', 'iptables.up.rules'))
  transfer iptables, '/tmp/iptables.up.rules' do
    post :install, 'mv /tmp/iptables.up.rules /etc/'
    post :install, 'iptables-restore < /etc/iptables.up.rules'
    post :install, 'iptables -L'
  end
  
  #http://library.linode.com/getting-started#sph_set-the-hostname
  noop do
    #TODO but linode has an adequate default...
  end
  
  verify do
    has_file '/etc/banner'
    has_file '/etc/ssh/sshd_config'
    has_file '/etc/iptables.up.rules'
  end
  
end

package :system_update do
  description 'System update'
  
  pre :install, 'apt-get update', :sudo => true
  pre :install, 'apt-get upgrade', :sudo => true
end