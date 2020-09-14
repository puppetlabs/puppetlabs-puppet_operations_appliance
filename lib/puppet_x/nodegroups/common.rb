module PuppetX; end
module PuppetX::Nodegroups; end

module PuppetX::Nodegroups::Common
  # Transform the node group array in to a hash
  # with a key of the name and an attribute
  # hash of the rest.
  def self.hashify_group_array(group_array)
    hashified = {}

    group_array.each do |group|
      hashified[group['name']] = group
    end

    hashified
  end

  def self.sort_hash(data)
    newhash = {}
    if data.is_a?(Hash)
      # .to_h method doesn't exist until Ruby 2.1.x
      data.sort.flatten(1).each_slice(2) { |a, b| newhash[a] = b }
    end
    newhash.each do |k, v|
      newhash[k] = if v.is_a?(Hash)
                     sort_hash(v)
                   else
                     v
                   end
    end
    newhash
  end
end
