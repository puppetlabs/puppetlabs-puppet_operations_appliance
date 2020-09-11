require 'puppet/util/nodegroups_api'
require 'puppet_x/nodegroups/common'

module Puppet::Parser::Functions
  newfunction(:nodegroups, :type => :rvalue) do |args|
    node_name = args[0]
    raise ArgumentError, 'Function accepts a single String' unless (
      args.length == 0 or
      ( args.length == 1 and node_name.is_a?(String) )
    )

    ng     = Puppet::Util::Nodegroups_api.new
    groups = ng.get_groups

    # When querying a specific group
    if args.length == 1
      # Assuming there is only one group by the name
      PuppetX::Nodegroups::Common.hashify_group_array(
        groups.select { |g| g['name'] == node_name }
      )
    else
      PuppetX::Nodegroups::Common.hashify_group_array(groups)
    end
  end
end
