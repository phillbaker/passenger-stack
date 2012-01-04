package :mysql, :provides => :database do
  description 'MySQL Database'
  apt %w( mysql-server mysql-client libmysqlclient15-dev )
  
  verify do
    has_executable 'mysqld'
    has_executable 'mysql'
  end
  
  optional :mysql_driver
end
 
package :mysql_driver, :provides => :ruby_database_driver do
  description 'Ruby MySQL database driver'
  gem 'mysql2'
  
  verify do
    has_gem 'mysql2'
  end
  
  requires :ruby
end
