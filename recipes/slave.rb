
require 'jenkins_api_client'

url = node['jenkins']['http_proxy']['host_name']
username = node['jenkins']['http_proxy']['basic_auth_username']
password = node['jenkins']['http_proxy']['basic_auth_password']

@client = JenkinsApi::Client.new(server_url: "http://#{username}:#{password}@#{url}")

node['jenkins-json']['slave'].each do |name, options|
  @client.node.create_dumb_slave(
                                 name: name,
                                 slave_host: options['slave_host'],
                                 private_key_file: options['/root/.ssh/id_rsa'],
                                 executors: options['executors'],
                                 labels: options['labels']
                                 )
end
