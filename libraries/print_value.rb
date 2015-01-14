module Extensions
  module Templates

    # An extension method for convenient printing of values in ERB templates.
    #
    # The method provides several ways how to evaluate the value:
    #
    # 1. Using the key as a node attribute:
    #
    #    <%= print_value 'bar' -%> is evaluated as: `node.elasticsearch142[:bar]`
    #
    #    You may use a dot-separated key for nested attributes:
    #
    #    <%= print_value 'foo.bar' -%> is evaluated in multiple ways in this order:
    #
    #    a) as `node.elasticsearch142['foo.bar']`,
    #    b) as `node.elasticsearch142['foo_bar']`,
    #    c) as `node.elasticsearch142.foo.bar` (ie. `node.elasticsearch142[:foo][:bar]`)
    #
    # 2. You may also provide an explicit value for the method, which is then used:
    #
    #    <%= print_value 'bar', node.elasticsearch142[:foo] -%>
    #
    # You may pass a specific separator to the method:
    #
    #    <%= print_value 'bar', separator: '=' -%>
    #
    # Do not forget to use an ending dash (`-`) in the ERB block, so lines for missing values are not printed!
    #
    def print_value key, value=nil, options={}
      separator = options[:separator] || ': '
      existing_value   = value

      # NOTE: A value of `false` is valid, we need to check for `nil` explicitely
      existing_value = node.elasticsearch142[key] if existing_value.nil? and not node.elasticsearch142[key].nil?
      existing_value = node.elasticsearch142[key.tr('.', '_')] if existing_value.nil? and not node.elasticsearch142[key.tr('.', '_')].nil?
      existing_value = key.to_s.split('.').inject(node.elasticsearch142) { |result, attr| result[attr] } rescue nil if existing_value.nil?

      [key, separator, existing_value.to_s, "\n"].join unless existing_value.nil?
    end

  end
end
