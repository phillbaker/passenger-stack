require File.join(File.dirname(__FILE__),'common.rb')

$:<< File.join(File.dirname(__FILE__), 'packages')

module Sprinkle::Package
  @@capistrano = {}

  def self.set_variables=(set)
    @@capistrano = set
  end

  def self.fetch(name)
    @@capistrano[name]
  end
  
  def self.exists?(name)
    @@capistrano.key?(name)
  end
end

# Require the stack we want
%w(database_mysql database_sqlite essential git gems image_management ruby_mri webserver_apache).each do |lib|
  require lib
end

# What we're installing to your server
# Take what you want, leave what you don't
# Build up your own and strip down your server until you get it right. 
policy :passenger_stack, :roles => :target do
  requires :webserver               # Apache
  requires :appserver               # Passenger
  requires :ruby                      # MRI Ruby (or REE)
  requires :image_management        # ImageMagick
  requires :gems                   # common gems
  requires :mysql                # MySQL and SQLite (or MongoDB or Postgres)
  #requires :sqlite
  requires :scm                     # Git
  # requires :memcached               # Memcached
  # requires :libmemcached            # Libmemcached
end

# Depend on a specific version of sprinkle 
begin
  gem 'sprinkle', ">= 0.3.3" 
rescue Gem::LoadError
  puts "sprinkle 0.3.3 required.\n Run: `sudo gem install sprinkle`"
  exit
end

run_deployment