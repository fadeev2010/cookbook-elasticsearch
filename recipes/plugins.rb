sdirectory "#{node.elasticsearch142[:dir]}/elasticsearch-#{node.elasticsearch142[:version]}/plugins/" do
  owner node.elasticsearch142[:user]
  group node.elasticsearch142[:user]
  mode 0755
  recursive true
end

node[:elasticsearch][:plugins].each do | name, config |
  next if name == 'elasticsearch/elasticsearch-cloud-aws' && !node.recipe?('aws')
  install_plugin name, config
end
