
chef_gem 'jenkins_api_client'

include_recipe 'jenkins-json::slave' unless node['jenkins']['slave'].nil?
