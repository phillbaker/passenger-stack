# Fill slice_url in - where you're installing your stack to
role :target, 'your-host-name-or-ip'

# the admin user we will run the commands as on the server, needs sudo priveleges
# pass in a block so that it's lazily evaluated, defaults to the current user
set :user do 
  exists?(:initial_run) ? 'root' : 'branch' 
end

set :domain, 'example.com' #domain names to create directories for
set :wordpress, 'blog.example.com' #sub-domain at which the wordpress is extracted

#ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa")] 
default_run_options[:pty] = true
Sprinkle::Package::Package.set_variables = self.variables if Package.respond_to?(:set_variables)
