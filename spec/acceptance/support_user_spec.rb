require 'spec_helper_acceptance'
describe 'tasks' do
  it 'task not to fail and password to be created ' do
    result = run_bolt_task('rsan::supportuser')
    expect(result['result']['_output']).to match('created')
  end
end
