package :postfix, :provides => :mailserver do
  description "Postfix - mail server"

  preseed_file = '/tmp/postfix.preseed'
  preseed_template = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'assets', 'postfix', 'postfix.preseed.erb'))
  
  transfer preseed_template, preseed_file, :render => true
  
  apt 'postfix' do
    pre :install, "debconf-set-selections #{preseed_file}"
  end

  verify do
    has_executable 'postfix'
    has_file '/etc/init.d/postfix'
  end
  
  requires :apt_utils
end