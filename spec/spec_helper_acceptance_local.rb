# frozen_string_literal: true

require 'singleton'
require 'serverspec'
require 'puppetlabs_spec_helper/module_spec_helper'
require 'puppet_litmus'
include PuppetLitmus
RSpec.configure do |c|
  c.mock_with :rspec
end
