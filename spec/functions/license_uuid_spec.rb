require 'spec_helper'

# let's define a typical license content string here

license = <<-LICENSE
  #######################
  # Begin License File #
  #######################
  # RSPEC TEST LICENSE - NOT FOR REUSE
  uuid: 0000111122223333444455556666777788889999
  to: "Rspec Test"
  nodes: 1
  end: 9999-99-99
  #####################
  # End License File #
  #####################
LICENSE

describe 'rsan::license_uuid' do
  it { is_expected.to run.with_params(license).and_return('0000111122223333444455556666777788889999') }
end
