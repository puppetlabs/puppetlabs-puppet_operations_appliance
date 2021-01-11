# frozen_string_literal: true

require 'spec_helper'

describe 'rsan::importer' do
  before :each do
    Puppet::Parser::Functions.newfunction(:puppetdb_query, type: :rvalue, arity: 1) do |_args|
      []
    end
  end
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
