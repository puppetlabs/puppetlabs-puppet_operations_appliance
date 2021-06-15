require 'spec_helper_acceptance'

describe 'Exporter class' do
  context 'activates module default parameters' do
    it 'applies the class with default parameters' do
      run_shell('/bin/echo "File { backup => false }
node default {
  # This is where you can declare classes for all nodes.
  class { \'rsan::exporter\': }
             }" > /etc/puppetlabs/code/environments/production/manifests/site.pp')

      expect { run_shell('/opt/puppetlabs/bin/puppet agent -t') }.to raise_error do |error|
        expect(error.message).to match %r{"exit_code"=>2}
      end
 #     expect(run_shell('/opt/puppetlabs/bin/puppet agent -t').exit_code).to eq(0)
    end
  end
end
