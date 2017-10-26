require 'spec_helper_acceptance'

describe 'apply task' do
  it 'inline code' do
    result = run_puppet_task(task_name: 'puppeteer::apply', params: 'code="notify { \$operatingsystem: }"')
    expect_multiple_regexes(result: result, regexes: [%r{\(notice\): defined 'message' as 'CentOS'}, %r{Job completed. 1/1 nodes succeeded}])
  end
end
