def run_deployment
  deployment do
    # mechanism for deployment
    delivery :capistrano do
      begin
        recipes 'Capfile'
      rescue LoadError
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