node.default[:elasticsearch142][:plugin][:mandatory] = Array(node[:elasticsearch142][:plugin][:mandatory] | ['cloud-aws'])

install_plugin "elasticsearch/elasticsearch-cloud-aws/#{node.elasticsearch['plugins']['elasticsearch/elasticsearch-cloud-aws']['version']}"
