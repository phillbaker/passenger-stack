package :php do
  description 'PHP Interpreter'
  #this also enables it for apache, no need to a2enmod php5...
  apt 'php5 libapache2-mod-php5 php5-mysql php5-gd php5-cli'

  verify do
    has_executable 'php'
  end
end