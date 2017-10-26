require 'spec_helper_acceptance'

describe 'external_fact task' do
  it 'set datacenter fact' do
    result = run_puppet_task(task_name: 'puppeteer::external_fact', params: 'fact=datacenter value=rhode_island')
    expect_multiple_regexes(result: result, regexes: [%r{new_value : rhode_island}, %r{Job completed. 1/1 nodes succeeded}])
  end
end
