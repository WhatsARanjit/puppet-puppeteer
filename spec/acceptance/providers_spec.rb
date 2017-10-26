require 'spec_helper_acceptance'

describe 'providers task' do
  it 'lookup providers for user type' do
    result = run_puppet_task(task_name: 'puppeteer::providers', params: 'type=user')
    expect_multiple_regexes(result: result, regexes: [%r{providers : \[\"useradd\"\]}, %r{Job completed. 1/1 nodes succeeded}])
  end
end
