
url = node['jenkins']['http_proxy']['host_name']
username = node['jenkins']['http_proxy']['basic_auth_username']
password = node['jenkins']['http_proxy']['basic_auth_password']

if node['jenkins-json']['jobs']['prune']

  ruby_block "prune deleted jobs" do
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
      
      sjobs = @client.job.list_all()
      djobs = search(node["jenkins"]["jobs"]["databag"], "*:*")
      Chef::Log.info ("DDD #{djobs}")
      #        pjobs = sjobs - djobs
      
      #        pjobs.each do |job|
      #          Chef::Log.info ("jenkins-json wipe workspace for job: #{job}")
      #          @client.job.wipe_out_workspace(job)
      #          Chef::Log.info ("jenkins-json delete job: #{job}")
      #          @client.job.delete(job)
      #        end
      
    end
  end
end

