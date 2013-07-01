require 'mina/bundler'
require 'mina/rails'
require 'mina/git'

set :project, 'test'

set :domain, '192.168.0.17'
set :deploy_to, '/home/xavier/quantlab/test'
# Temporary dev path
#set :repository, 'xavier@192.168.0.12:/home/xavier/dev/projects/quantlab/test'
set :repository, 'xavier@192.168.0.12:' + Dir.pwd  + '/test'
set :branch, 'master'

set :term_mode, :pretty

# Optional settings:
set :user, 'xavier'    # Username in the server to SSH to.

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  #queue! %[mkdir -p "#{deploy_to}/shared/log"]
  #queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]
  invoke :'git:clone'
  queue! %[./boostrap.sh link #{project}]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'

    to :launch do
      queue 'echo "Nothing for now"'
      queue './boostrap.sh run'
    end
  end
end