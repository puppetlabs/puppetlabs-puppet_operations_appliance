require 'spec_helper_acceptance'
describe 'tasks' do
  it 'task not to fail and password to be created ' do
    result = run_bolt_task('rsan::supportuser')
    #    expect(result['result']['_output']).to match('"status" : "created",')
    expect(result[0]['status']).to eq('created')
  end
end
