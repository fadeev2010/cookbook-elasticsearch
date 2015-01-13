name             "droid-elasticsearch142"

maintainer       "karmi"
maintainer_email "karmi@karmi.cz"
license          "Apache"
description      "Installs and configures elasticsearch"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.markdown'))
version          "0.3.11"

depends 'ark', '>= 0.2.4'

recommends 'build-essential'
recommends 'xml'
recommends 'java'
recommends 'monit'

# provides 'elasticsearch'
# provides 'elasticsearch142::data'
# provides 'elasticsearch142::ebs'
# provides 'elasticsearch142::aws'
# provides 'elasticsearch142::nginx'
# provides 'elasticsearch142::proxy'
# provides 'elasticsearch142::plugins'
# provides 'elasticsearch142::monit'
# provides 'elasticsearch142::search_discovery'
