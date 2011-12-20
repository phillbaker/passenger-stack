require File.join(File.dirname(__FILE__),'common.rb')

$:<< File.join(File.dirname(__FILE__), 'packages')

#require all files in package
# Dir["#{File.dirname(__FILE__)}/packages/*.rb"].each do |f|
#   require f
# end

# Require the stack base we want
%w(gem_bundler database_mysql database_sqlite essential git image_management ruby_mri webserver_apache).each do |lib|
  require lib
end

# What we're installing to your server
# Take what you want, leave what you don't
# Build up your own and strip down your server until you get it right. 
policy :passenger_stack, :roles => :app do
  requires :webserver               # Apache
  #requires :appserver               # Passenger #TODO: /Users/phill/Documents/workspace/sprinkle/passenger-stack/.bundle/ruby/1.8/gems/capistrano-2.9.0/lib/capistrano/command.rb:176:in `process!': failed: "sh -c 'sudo -p '\\''sudo password: '\\'' gem install passenger --version '\\''3.0.8'\\'' --no-rdoc --no-ri'" on 173.230.155.35 (Capistrano::CommandError)
  requires :ruby                      # MRI Ruby (or REE)
  requires :image_management        # ImageMagick
  requires :bundler                   # Bundler
  requires :mysql                # MySQL and SQLite (or MongoDB or Postgres)
  requires :sqlite
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