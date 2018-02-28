require 'spec_helper_acceptance'

describe 'classfile task' do
  it 'read classfile.txt' do
    result = run_puppet_task(task_name: 'puppeteer::classfile')
    expect_multiple_regexes(result: result, regexes: [%r{settings}, %r{Job completed. 1/1 nodes succeeded}])
  end
end
