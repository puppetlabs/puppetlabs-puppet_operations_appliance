RSpec.configure do |c|
  c.hiera_config = File.expand_path(File.join(__dir__, 'fixtures/hiera.yaml'))
  puts c.hiera_config
end