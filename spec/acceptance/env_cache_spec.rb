require 'spec_helper_acceptance'

describe 'env_cache task' do
  it 'clear environment cache for production' do
    result = run_puppet_task(task_name: 'puppeteer::env_cache', params: 'environment=production')
    expect_multiple_regexes(result: result, regexes: [%r{responsecode : 204}, %r{Job completed. 1/1 nodes succeeded}])
  end
end
