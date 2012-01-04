require File.join(File.dirname(__FILE__),'common.rb')
require File.join(File.dirname(__FILE__), 'packages', 'essential.rb')

policy :system_update, :roles => [:target] do
  requires :system_update
end

run_deployment
