require 'spec_helper_acceptance'

describe 'features task' do
  it 'lookup features' do
    result = run_puppet_task(task_name: 'puppeteer::features')
    expect_multiple_regexes(result: result, regexes: [%r{features : \[.*"posix".*\]}, %r{features : \[.*"root".*\]}, %r{Job completed. 1/1 nodes succeeded}])
  end
end
