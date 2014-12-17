name 'jenkins-json'
maintainer 'Vasiliy Tolstov'
maintainer_email 'v.tolstov@selfip.ru'
license 'CC0 1.0 Universal'
description 'Configures jenkins via json api'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.0.1'

recipe 'jenkins-json', 'Install require gem and configure jenkins from node attributes'
recipe 'jenkins-json::slave', 'Configure jenkins slaves from node attributes'


%w(debian ubuntu suse exherbo).each do |os|
  supports os
end
