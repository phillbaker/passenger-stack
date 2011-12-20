#run when passing this off to a new maintainer or starting a new box
# this creates the default account and adds the current users' ssh key to admin
# this should prompt for root password once and then all other commands should be password free

# who we want to add the our public key as an authorized user for
# admin = all priveleges, sudo = run without password (ie good for sprinkle/server maintenance)
$users = {'branch' => [:admin, :sudo], `whoami`.strip => [:admin]}

require File.join(File.dirname(__FILE__), 'common.rb')
require File.join(File.dirname(__FILE__), 'packages', 'user_setup.rb')

policy :add_public_key, :roles => [:target] do
  requires :add_my_key_to_authorized
end

run_deployment
