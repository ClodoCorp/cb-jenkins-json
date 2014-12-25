
chef_gem 'jenkins_api_client'

include_recipe 'jenkins-json::slave' unless node['jenkins-json']['slave'].nil?
include_recipe 'jenkins-json::jobs' unless node['jenkins-json']['jobs'].nil?
