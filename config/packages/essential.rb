package :build_essential do
  description 'Build tools'
  
  apt 'build-essential' do
    pre :install, 'apt-get update'
  end
  
  requires :apt_essential
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
  apt %w(sudo vim screen gcc make ssh wget) do
    banner = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'assets', 'etc', 'banner'))
    transfer banner, '/etc/banner', :sudo => true
    
    ssh = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'assets', 'etc', 'ssh', 'sshd_config'))
    transfer ssh, '/etc/ssh/sshd_config', :sudo => true do
      post :install, 'service ssh restart', :sudo => true #restart ssh
    end
    
    ssh = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'assets', 'etc', 'iptables.up.rules'))
    transfer ssh, '/etc/iptables.up.rules', :sudo => true do
      post :install, 'iptables-restore < /etc/iptables.up.rules', :sudo => true
      post :install, 'iptables -L', :sudo => true
    end
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