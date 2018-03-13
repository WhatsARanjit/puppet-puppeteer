require 'spec_helper_acceptance'

describe 'apply task' do
  it 'inline code' do
    result_inline = run_puppet_task(task_name: 'puppeteer::apply', params: 'code="notify { \$operatingsystem: }"')
    expect_multiple_regexes(result: result_inline, regexes: [%r{\(notice\): defined 'message' as 'CentOS'}, %r{Job completed. 1/1 nodes succeeded}])
  end
  it 'custom modulepath' do
    result_modulepath = run_puppet_task(task_name: 'puppeteer::apply', params: 'code="notify { \$settings::modulepath: }" modulepath="/tmp"')
    expect_multiple_regexes(result: result_modulepath, regexes: [%r{\(notice\): defined 'message' as '/tmp'}, %r{Job completed. 1/1 nodes succeeded}])
  end
end
