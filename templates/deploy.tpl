require 'mina/bundler'
require 'mina/rails'
require 'mina/git'

set :domain, '{{ remote_ip }}'
set :deploy_to, '/home/{{ user }}/quantlab/{{ deploy }}'
# Temporary dev path
#set :repository, '{{ user }}@{{ ip }}:/home/{{ user }}/dev/projects/quantlab/{{ deploy }}'
set :repository, '{{ user }}@{{ ip }}:' + Dir.pwd  + '/{{ deploy }}'
set :branch, 'master'

set :term_mode, :pretty

# Optional settings:
set :user, '{{ user }}'    # Username in the server to SSH to.

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  #queue! %[mkdir -p "#{deploy_to}/shared/log"]
  #queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'

    to :launch do
      queue 'echo "Nothing for now"'
    end
  end
end
