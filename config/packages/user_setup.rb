# who we want to add the our public key as an authorized user for
# this needs to run as root...
# admin = all priveleges, sudo = run without password (ie good for sprinkle/server maintenance)
# $users = {'branch' => [:admin, :sudo], `whoami`.strip => [:admin]}
# 
# policy :add_public_key, :roles => [:target_box] do
#   requires :add_my_key_to_authorized
# end

#for debian-based systems (tested on Ubuntu 10.4 LTS), uses id_dsa for ssh keys
if not $users and not $user
  puts "$user not specified, make_user tasks not available"
else
  $users = [$user] unless $users
  dsa = true #flag for dsa or rsa
  
  # we build lots of pseudo packages, one for each user we want to operate on
  $users.each do |user, roles|
    package "create_user_#{user}" do
      noop do
        # Do not use the adduser command, it prompts for input and will hang
        # This will create users with no passwords, but...
        # ...our sshd config ignores empty passwords so external users can't login
        # ...and users can just ssh in and change their passwords with passwd
        # Alternative is to read passwords from a config.yml or something
        pre :install, "groupadd -f #{user}"
        pre :install, "useradd -s /bin/bash -m -g #{user} #{user} || true"
        roles.each do |role|
          pre :install, "adduser #{user} #{role}"
        end
      end
      verify do
        has_file "/home/#{user}/.bashrc"
      end
      requires :create_web_group
      requires :change_umask
    end
    
    package "create_ssh_dirs_#{user}" do
      requires "create_user_#{user}"
      noop do
        pre :install, "mkdir -p /home/#{user}/.ssh"
        pre :install, "touch /home/#{user}/.ssh/id_#{dsa ? 'd' : 'r'}sa"
        pre :install, "touch /home/#{user}/.ssh/id_#{dsa ? 'd' : 'r'}sa.pub"
        pre :install, "touch /home/#{user}/.ssh/authorized_keys"
        pre :install, "chown -R #{user}:#{user} /home/#{user}/.ssh/"
        pre :install, "chmod 0600 /home/#{user}/.ssh/id_#{dsa ? 'd' : 'r'}sa"
      end
    
      verify do
        has_file "/home/#{user}/.ssh/id_#{dsa ? 'd' : 'r'}sa.pub"
        has_file "/home/#{user}/.ssh/authorized_keys"
      end
    end
    
    
    package "generate_private_ssh_keys_#{user}" do
      requires "create_ssh_dirs_#{user}"
      noop do
        pre :install, "ssh-keygen -t #{dsa ? 'd' : 'r'}sa -N '' -f /home/#{user}/.ssh/id_#{dsa ? 'd' : 'r'}sa"
      end
    
      verify do
        has_file "/home/#{user}/.ssh/id_#{dsa ? 'd' : 'r'}sa"
      end
    end
    
    local_public_key_path = File.join(ENV["HOME"], ".ssh", "id_#{dsa ? 'd' : 'r'}sa.pub")
    if File.exists?(local_public_key_path)
      package "add_my_key_to_authorized_#{user}" do
        requires "create_ssh_dirs_#{user}", "update_sudoers_#{user}"
        
        config_file = "/home/#{user}/.ssh/authorized_keys"
        config_text = File.open(local_public_key_path).read.lstrip
      
        push_text config_text, config_file, :sudo => false
      
        verify do
          file_contains config_file, config_text.slice(0,100)
        end
      end
    else
      package "add_my_key_to_authorized_#{user}" do
      end
      puts "no public key at: #{local_public_key_path} so adding keys is unavailable"
    end
    
    #allow members of group sudo to not need a password
    package "update_sudoers_#{user}" do
      config_file = "/etc/sudoers"
      config_text = "%sudo ALL=NOPASSWD: ALL" 
      
      #TODO this doesn't replace the %sudo ALL=(ALL) ALL that's already in the file
      push_text config_text, config_file, :sudo => true
    
      verify do
        file_contains config_file, config_text
      end
    end
  end #$users.each
  
  package :add_my_key_to_authorized do
    $users.each do |user, roles|
      requires "add_my_key_to_authorized_#{user}"
    end
  end #:add_my_key_to_authorized
  
  package :make_user do
    $users.each do |user, roles|
      requires "create_user_#{user}"
      requires "generate_private_ssh_keys_#{user}"
    end
  end #:make_user
  
  
  package :create_web_group do
    noop do
      pre :install, 'groupadd -f www-pub'
    end
  end
  
  package :change_umask do
    #Change the umask for users
    #files will have 664 and directories 775
    #files created by one user will be writable by other users in the www-group without needing to chmod them
    replace_text 'umask 022', 'umask 0002', '/etc/profile', :sudo => true
    
    verify do
      file_contains '/etc/profile', 'umask 0002'
    end
  end
end #else
