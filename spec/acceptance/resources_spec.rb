require 'spec_helper_acceptance'

describe 'resources task' do
  it 'read resources.txt' do
    result = run_puppet_task(task_name: 'puppeteer::resources')
    expect_multiple_regexes(result: result, regexes: [%r{Job completed. 1/1 nodes succeeded}])
  end
end
