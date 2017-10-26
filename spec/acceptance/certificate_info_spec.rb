require 'spec_helper_acceptance'

describe 'certificate_info task' do
  it 'lookup certificate_info' do
    result = run_puppet_task(task_name: 'puppeteer::certificate_info')
    expect_multiple_regexes(result: result, regexes: [%r{Job completed. 1/1 nodes succeeded}])
  end
  it 'lookup certificate_info within 1m range' do
    result = run_puppet_task(task_name: 'puppeteer::certificate_info', params: 'threshold=1m')
    expect_multiple_regexes(result: result, regexes: [%r{Job completed. 1/1 nodes succeeded}])
  end
  it 'lookup certificate_info within 6y range with no fail' do
    result = run_puppet_task(task_name: 'puppeteer::certificate_info', params: 'threshold=6y fail=no_fail')
    expect_multiple_regexes(result: result, regexes: [%r{Job completed. 1/1 nodes succeeded}])
  end
end
