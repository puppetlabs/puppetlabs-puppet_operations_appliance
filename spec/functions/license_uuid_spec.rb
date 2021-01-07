require 'spec_helper'

# let's define a typical license content string here

license = <<-LICENSE
  #######################
  # Begin License File #
  #######################
  # PUPPET ENTERPRISE LICENSE - Puppet Labs
  uuid: f13f0fe69ad3bf67e842c8473afaf12913e14516
  to: "Puppet Labs"
  nodes: 5000
  end: 2030-08-04
  #####################
  # End License File #
  #####################
LICENSE

describe 'rsan::license_uuid' do
  it { is_expected.to run.with_params(license).and_return('f13f0fe69ad3bf67e842c8473afaf12913e14516') }
end
