require 'spec_helper_acceptance'

describe 'Exporter class' do
  context 'activates module default parameters' do
    it 'applies the class with default parameters' do
      pp = <<-MANIFEST
        include rsan::exporter
        MANIFEST

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).not_to eq(1)
      expect(apply_manifest(pp).exit_code).not_to eq(1)
      idempotent_apply(pp)
    end
  end
end
