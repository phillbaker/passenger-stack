def run_deployment(initial = false)
  deployment do
    # mechanism for deployment
    delivery :capistrano do
      begin
        recipes 'config/initial.rb' if initial
        recipes 'Capfile'
      rescue LoadError
        recipes 'initial' if initial
        recipes 'deploy'
      end
    end

    # source based package installer defaults
    source do
      prefix   '/usr/local'
      archives '/usr/local/sources'
      builds   '/usr/local/build'
    end
  end
end
