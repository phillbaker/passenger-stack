package :build_essential do
  description 'Build tools'
  apt 'build-essential' do
    pre :install, 'apt-get update'
  end
end

package :apt_essential do
  #sudo vim mysql-server mysql-client screen gcc make libc6-dev zlib1g-dev libssl-dev libmysqlclient15-dev apache2 libreadline5-dev php5 php5-cli php5-mysql postfix ssh python gettext python-setuptools proftpd
  #libmysqlclient15-dev mysql-server mysql-client libreadline5-dev screen gcc make libc6-dev zlib1g-dev libssl-dev libmysqlclient15-dev apache2 libreadline5-dev gettext
  apt %w(mysql-server sudo vim screen gcc make ssh)
end