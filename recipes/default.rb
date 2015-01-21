[Chef::Recipe, Chef::Resource].each { |l| l.send :include, ::Extensions }

Erubis::Context.send(:include, Extensions::Templates)

elasticsearch = "elasticsearch-#{node.elasticsearch142[:version]}"

include_recipe "droid-elasticsearch142::curl"
include_recipe "ark"

# Create user and group
#
group node.elasticsearch142[:user] do
  gid node.elasticsearch[:gid]
  action :create
  system true
end

user node.elasticsearch142[:user] do
  comment "ElasticSearch User"
  home    "#{node.elasticsearch142[:dir]}/elasticsearch"
  shell   "/bin/bash"
  uid     node.elasticsearch[:uid]
  gid     node.elasticsearch142[:user]
  supports :manage_home => false
  action  :create
  system true
end

# FIX: Work around the fact that Chef creates the directory even for `manage_home: false`
bash "remove the elasticsearch user home" do
  user    'root'
  code    "rm -rf  #{node.elasticsearch142[:dir]}/elasticsearch"
  not_if  { ::File.symlink?("#{node.elasticsearch142[:dir]}/elasticsearch") }
  only_if { ::File.directory?("#{node.elasticsearch142[:dir]}/elasticsearch") }
end


# Create ES directories
#
[ node.elasticsearch142[:path][:conf], node.elasticsearch142[:path][:logs] ].each do |path|
  directory path do
    owner node.elasticsearch142[:user] and group node.elasticsearch142[:user] and mode 0755
    recursive true
    action :create
  end
end

# My_changes
directory node.elasticsearch[:pid_path] do
  owner node.elasticsearch142[:user] and group node.elasticsearch142[:user] and mode 0755
  recursive true
end

# Create data path directories
#
data_paths = node.elasticsearch142[:path][:data].is_a?(Array) ? node.elasticsearch142[:path][:data] : node.elasticsearch142[:path][:data].split(',')

data_paths.each do |path|
  directory path.strip do
    owner node.elasticsearch142[:user] and group node.elasticsearch142[:user] and mode 0755
    recursive true
    action :create
  end
end

# Create service
#
template "/etc/init.d/elasticsearch142" do
  source "elasticsearch.init.erb"
  owner 'root' and mode 0755
end

service "elasticsearch142" do
  supports :status => true, :restart => true
  action [ :enable ]
end

# Download, extract, symlink the elasticsearch libraries and binaries
#
ark_prefix_root = node.elasticsearch142[:dir] || node.ark[:prefix_root]
ark_prefix_home = node.elasticsearch142[:dir] || node.ark[:prefix_home]

filename = node.elasticsearch[:filename] || "elasticsearch-#{node.elasticsearch142[:version]}.tar.gz"
download_url = node.elasticsearch[:download_url] || [node.elasticsearch[:host],
                node.elasticsearch[:repository], filename].join('/')

ark "elasticsearch142" do
  url   download_url
  owner node.elasticsearch142[:user]
  group node.elasticsearch142[:user]
  version node.elasticsearch142[:version]
  has_binaries ['bin/elasticsearch', 'bin/plugin']
  checksum node.elasticsearch[:checksum]
  prefix_root   ark_prefix_root
  prefix_home   ark_prefix_home

  notifies :start,   'service[elasticsearch142]' unless node.elasticsearch[:skip_start]
  notifies :restart, 'service[elasticsearch142]' unless node.elasticsearch[:skip_restart]

  not_if do
    link   = "#{node.elasticsearch142[:dir]}/elasticsearch"
    target = "#{node.elasticsearch142[:dir]}/elasticsearch-#{node.elasticsearch142[:version]}"
    binary = "#{target}/bin/elasticsearch"

    ::File.directory?(link) && ::File.symlink?(link) && ::File.readlink(link) == target && ::File.exists?(binary)
  end
end

# Increase open file and memory limits
#
bash "enable user limits" do
  user 'root'

  code <<-END.gsub(/^    /, '')
    echo 'session    required   pam_limits.so' >> /etc/pam.d/su
  END

  not_if { ::File.read("/etc/pam.d/su").match(/^session    required   pam_limits\.so/) }
end

log "increase limits for the elasticsearch user"

file "/etc/security/limits.d/10-elasticsearch142.conf" do
  content <<-END.gsub(/^    /, '')
    #{node.elasticsearch.fetch(:user, "elasticsearch142")}     -    nofile    #{node.elasticsearch[:limits][:nofile]}
    #{node.elasticsearch.fetch(:user, "elasticsearch142")}     -    memlock   #{node.elasticsearch[:limits][:memlock]}
  END
end

# Create file with ES environment variables
#
template "elasticsearch-env.sh" do
  path   "#{node.elasticsearch142[:path][:conf]}/elasticsearch-env.sh"
  source node.elasticsearch142[:templates][:elasticsearch_env]
  owner  node.elasticsearch142[:user] and group node.elasticsearch142[:user] and mode 0755

  notifies :restart, 'service[elasticsearch142]' unless node.elasticsearch[:skip_restart]
end

# Create ES config file
#
template "elasticsearch.yml" do
  path   "#{node.elasticsearch142[:path][:conf]}/elasticsearch.yml"
  source node.elasticsearch142[:templates][:elasticsearch_yml]
  owner  node.elasticsearch142[:user] and group node.elasticsearch142[:user] and mode 0755

  notifies :restart, 'service[elasticsearch142]' unless node.elasticsearch[:skip_restart]
end

# Create ES logging file
#
template "logging.yml" do
  path   "#{node.elasticsearch142[:path][:conf]}/logging.yml"
  source node.elasticsearch[:templates][:logging_yml]
  owner  node.elasticsearch142[:user] and group node.elasticsearch142[:user] and mode 0755

  notifies :restart, 'service[elasticsearch142]' unless node.elasticsearch[:skip_restart]
end
