package :php do
  description 'PHP Interpreter'
  #this also enables it for apache, no need to a2enmod php5...
  apt 'php5 libapache2-mod-php5 php5-mysql php5-gd php5-cli' do
    #links created by apt are bad, as of this writing, so delete/recreate
    post :install, 'a2dismod php5'
    post :install, 'a2enmod php5'
    post :install, 'apache2ctl graceful'
  end

  verify do
    has_executable 'php'
  end
end