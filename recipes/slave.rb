
url = node['jenkins']['http_proxy']['host_name']
username = node['jenkins']['http_proxy']['basic_auth_username']
password = node['jenkins']['http_proxy']['basic_auth_password']

ruby_block "jenkins-json waiting server" do
  block do
    require 'jenkins_api_client'
    @client = JenkinsApi::Client.new(server_url: "http://#{username}:#{password}@#{url}", :follow_redirects => true)
    while true
      begin
        nodes = @client.node.list()
        if nodes.length() > 0
          break
        end
      rescue
        Chef::Log.info ("jenkins-json waiting for master")
        sleep 3
      end
    end
  end
end


node['jenkins-json']['slave'].each do |name, options|
  ruby_block "create_slave_#{name}" do
    block do
      require 'jenkins_api_client'
      @client = JenkinsApi::Client.new(server_url: "http://#{username}:#{password}@#{url}", :follow_redirects => true)

      if name == 'master'
        conf = @client.node.get_config(name)
        conf = conf.sub(/<numExecutors>([0-9]+)<\/numExecutors>/, "<numExecutors>#{options['executors']}</numExecutors>")
        @client.node.post_config(name, conf)
        next
      end
      begin
        @client.node.delete(name)
      rescue
        Chef::Log.info ("jenkins-json unable to delete node #{name}")
      end

      while @client.node.index(name).instance_of? Array
        @client.node.create_dumb_slave(name: name, slave_host: options['slave_host'],
                                       slave_port: options['slave_port'], slave_user: options['slave_user'],
                                       credentials_id: options['credentials_id'],
                                       private_key_file: options['private_key_file'],
                                       executors: options['executors'], labels: options['labels'],
                                       remote_fs: options['remote_fs'], mode: options['mode'])
        Chef::Log.info ("jenkins-json waiting for slave #{name}")
        sleep 3
      end

      conf = @client.node.get_config(name)
      Chef::Log.info ("jenkins-json rewrite userId from anonymous to jenkins")
      conf = conf.sub(/<userId>anonymous<\/userId>/, "<userId>jenkins</userId>")
      @client.node.post_config(name, conf)

    end
    action :nothing
  end

  ruby_block "notify_slave_#{name}" do
    block do
    end
    notifies :create, 'ruby_block[create_slave_#{name}]', :delayed
  end

end
