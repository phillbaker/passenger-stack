# Run when passing this off to a new maintainer or starting a new box.
#  When first run, this will need root password.
#  This creates the default account and adds the current users' ssh key to admin
#  This should prompt for root password once and then all other commands should be password free

# Who we want to add the our public key as an authorized user for.
#  admin = all priveleges, sudo = run without password (ie good for sprinkle/server maintenance)
#  branch = seen more than root (get it?)
#  git = for capistrano deployment purposes/hosting git projects
#  www-pub = group that can edit /var/www stuff
# TODO use set :users, {...} and then fetch(:users) in the package file instead of the global variables, better form.
$users = {'branch' => [:admin, :sudo, :'www-pub'], 'git' => [], `whoami`.strip => [:admin, :'www-pub']} 


require File.join(File.dirname(__FILE__),'common.rb')
require File.join(File.dirname(__FILE__), 'packages', 'user_setup.rb')

policy :add_public_key, :roles => [:target] do
  requires :add_my_key_to_authorized
end

run_deployment(true)
