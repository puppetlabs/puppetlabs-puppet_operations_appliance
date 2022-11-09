# frozen_string_literal: true

require 'spec_helper'

describe 'puppet_operations_appliance::importer' do
  before :each do
    Puppet::Parser::Functions.newfunction(:puppetdb_query, type: :rvalue, arity: 1) do |_args|
      []
    end
    Puppet::Parser::Functions.newfunction(:pe_sort, type: :rvalue, arity: 1) do |_args|
      []
    end
  end
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) do
        <<-PRE_COND
        class puppet_enterprise::profile::controller {}
        class puppet_enterprise::params {$confdir =  "/etc/puppetlabs/puppet"}
        include puppet_enterprise::params
        define pe_ini_setting (
         $ensure,
         $path,
         $section,
         $setting,
         $value,
         ){}
        PRE_COND
      end

      it { is_expected.to compile }
    end
  end
end
