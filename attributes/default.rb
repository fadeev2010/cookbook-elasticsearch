# Load settings from data bag 'elasticsearch/settings'
#
settings = Chef::DataBagItem.load('elasticsearch', 'settings')[node.chef_environment] rescue {}
Chef::Log.debug "Loaded settings: #{settings.inspect}"

# Initialize the node attributes with node attributes merged with data bag attributes
#
node.default[:elasticsearch] ||= {}
node.normal[:elasticsearch]  ||= {}

include_attribute 'droid-elasticsearch142::customize'

node.normal[:elasticsearch]    = DeepMerge.merge(node.default[:elasticsearch].to_hash, node.normal[:elasticsearch].to_hash)
node.normal[:elasticsearch]    = DeepMerge.merge(node.normal[:elasticsearch].to_hash, settings.to_hash)


# === VERSION AND LOCATION
#
default.elasticsearch142[:version]       = "1.4.2"
default.elasticsearch142[:host]          = "http://download.elasticsearch.org"
default.elasticsearch142[:repository]    = "elasticsearch/elasticsearch"
default.elasticsearch142[:filename]      = nil
default.elasticsearch142[:download_url]  = nil

# === NAMING
#
default.elasticsearch142[:cluster][:name] = 'elasticsearch142'
default.elasticsearch142[:node][:name]    = 'elasticsearch142'

# === USER & PATHS
#
  default.elasticsearch142[:dir]       = "/opt/elasticsearch142"
  default.elasticsearch142[:bindir]    = "/opt/elasticsearch142/elasticsearch142/bin"
  default.elasticsearch142[:user]      = "elasticsearch142"
default.elasticsearch142[:uid]       = nil
default.elasticsearch142[:gid]       = nil

# default.elasticsearch142[:dir]       = "/usr/local"
# default.elasticsearch142[:bindir]    = "/usr/local/bin"
# default.elasticsearch142[:user]      = "elasticsearch"

  default.elasticsearch142[:path][:conf] = "/opt/elasticsearch142"
  default.elasticsearch142[:path][:data] = "/var/elasticsearch142/data"
  default.elasticsearch142[:path][:logs] = "/var/log/elasticsearch142"

# default.elasticsearch142[:path][:conf] = "/usr/local/etc/elasticsearch"
# default.elasticsearch142[:path][:data] = "/usr/local/var/data/elasticsearch"
# default.elasticsearch142[:path][:logs] = "/usr/local/var/log/elasticsearch"


default.elasticsearch142[:pid_path]  = "/var/run"
default.elasticsearch142[:pid_file]  = "#{node.elasticsearch142[:pid_path]}/#{node.elasticsearch142[:node][:name].to_s.gsub(/\W/, '_')}.pid"

default.elasticsearch142[:templates][:elasticsearch_env] = "elasticsearch-env.sh.erb"
default.elasticsearch142[:templates][:elasticsearch_yml] = "elasticsearch.yml.erb"
default.elasticsearch142[:templates][:logging_yml]       = "logging.yml.erb"

# === MEMORY
#
# Maximum amount of memory to use is automatically computed as one half of total available memory on the machine.
# You may choose to set it in your node/role configuration instead.
#
allocated_memory = "#{(node.memory.total.to_i * 0.6 ).floor / 1024}m"
default.elasticsearch142[:allocated_memory] = allocated_memory

# === GARBAGE COLLECTION SETTINGS
#
default.elasticsearch142[:gc_settings] =<<-CONFIG
  -XX:+UseParNewGC
  -XX:+UseConcMarkSweepGC
  -XX:CMSInitiatingOccupancyFraction=75
  -XX:+UseCMSInitiatingOccupancyOnly
  -XX:+HeapDumpOnOutOfMemoryError
CONFIG

# === LIMITS
#
# By default, the `mlockall` is set to true: on weak machines and Vagrant boxes,
# you may want to disable it.
#
default.elasticsearch142[:bootstrap][:mlockall] = ( node.memory.total.to_i >= 1048576 ? true : false )
default.elasticsearch142[:limits][:memlock] = 'unlimited'
default.elasticsearch142[:limits][:nofile]  = '64000'

# === PRODUCTION SETTINGS
#
default.elasticsearch142[:index][:mapper][:dynamic]   = true
default.elasticsearch142[:action][:auto_create_index] = true
default.elasticsearch142[:action][:disable_delete_all_indices] = true
default.elasticsearch142[:node][:max_local_storage_nodes] = 1

default.elasticsearch142[:discovery][:zen][:ping][:multicast][:enabled] = true
default.elasticsearch142[:discovery][:zen][:minimum_master_nodes] = 1
default.elasticsearch142[:gateway][:type] = 'local'
default.elasticsearch142[:gateway][:expected_nodes] = 1

default.elasticsearch142[:thread_stack_size] = "256k"

default.elasticsearch142[:env_options] = ""

# === OTHER SETTINGS
#
default.elasticsearch142[:skip_restart] = false
default.elasticsearch142[:skip_start] = false

# === PORT
#
default.elasticsearch142[:http][:port] = 9600

# === CUSTOM CONFIGURATION
#
default.elasticsearch142[:custom_config] = {}

# === LOGGING
#
# See `attributes/logging.rb`
#
default.elasticsearch142[:logging] = {}

# --------------------------------------------------
# NOTE: Setting the attributes for elasticsearch.yml
# --------------------------------------------------
#
# The template uses the `print_value` extension method to print attributes with a "truthy"
# value, set either in data bags, node attributes, role override attributes, etc.
#
# It is possible to set *any* configuration value exposed by the Elasticsearch configuration file.
#
# For example:
#
#     <%= print_value 'cluster.routing.allocation.node_concurrent_recoveries' -%>
#
# will print a line:
#
#     cluster.routing.allocation.node_concurrent_recoveries: <VALUE>
#
# if the either of following node attributes is set:
#
# * `node.cluster.routing.allocation.node_concurrent_recoveries`
# * `node['cluster.routing.allocation.node_concurrent_recoveries']`
#
# The default attributes set by the cookbook configure a minimal set inferred from the environment
# (eg. memory settings, node name), or reasonable defaults for production.
#
# The template is based on the elasticsearch.yml file from the Elasticsearch distribution;
# to set other configurations, set the `node.elasticsearch142[:custom_config]` attribute in the
# node configuration, `elasticsearch/settings` data bag, role/environment definition, etc:
#
#     // ...
#     'threadpool.index.type' => 'fixed',
#     'threadpool.index.size' => '2'
#     // ...
#
