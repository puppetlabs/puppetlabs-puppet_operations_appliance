require 'spec_helper'

# let's define a typical license content string here

license = <<-LICENSE
  #######################
  # Begin License File #
  #######################
  # PUPPET ENTERPRISE LICENSE - Puppet Labs
  uuid: ***REMOVED***
  to: "Puppet Labs"
  nodes: 5000
  end: 2030-08-04
  #####################
  # End License File #
  #####################
LICENSE

describe 'rsan::license_uuid' do
  it { is_expected.to run.with_params(license).and_return('***REMOVED***') }
end
