# frozen_string_literal: true

require 'spec_helper'

describe 'puppet_operations_appliance::exporter' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'service {"pe-puppetserver": }' }

      it { is_expected.to compile }
    end
  end
end
