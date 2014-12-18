
url = node['jenkins']['http_proxy']['host_name']
username = node['jenkins']['http_proxy']['basic_auth_username']
password = node['jenkins']['http_proxy']['basic_auth_password']

node['jenkins-json']['slave'].each do |slave|
  slave.each do |name, options|
    ruby_block "jenkins-json node #{name}" do
      block do
        require 'jenkins_api_client'
        @client = JenkinsApi::Client.new(server_url: "http://#{username}:#{password}@#{url}", :follow_redirects => true)

        begin
          @client.node.delete(name)
        rescue
          Chef::Log.info ("jenkins-json unable to delete node #{name}")
        end

        while @client.node.index(name).instance_of? Array
          @client.node.create_dumb_slave(name: name, slave_host: options['slave_host'],
                                         private_key_file: options['private_key_file'],
                                         executors: options['executors'], labels: options['labels'],
                                         remote_fs: options['remote_fs'])
          Chef::Log.info ("jenkins-json waiting for slave #{name}")
          sleep 1
        end

      end
    end
  end
end
