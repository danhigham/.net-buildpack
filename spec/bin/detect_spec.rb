# Cloud Foundry NET Buildpack
# Copyright (c) 2013 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'
require 'open3'

describe 'detect script', :integration do

  it 'should return zero if success' do
    Dir.mktmpdir do |root|
      FileUtils.cp_r 'spec/fixtures/integration_valid/.', root
      with_memory_limit('1G') do
        Open3.popen3("bin/detect #{root}") do |stdin, stdout, stderr, wait_thr|
          puts stdout.read if wait_thr.value != 0
          expect(wait_thr.value).to be_success
        end
      end
    end
  end

  it 'should fail to detect when no containers detect' do
     Dir.mktmpdir do |root|
      FileUtils.cp_r 'spec/fixtures/integration_no_container/.', root
      with_memory_limit('1G') do
        Open3.popen3("bin/detect #{root}") do |stdin, stdout, stderr, wait_thr|
          expect(wait_thr.value).to_not be_success
        end
      end
    end
  end

  it 'should handle Procfile' do
     Dir.mktmpdir do |root|
      FileUtils.cp_r 'spec/fixtures/procfile/.', root
      with_memory_limit('1G') do
        Open3.popen3("bin/detect #{root}") do |stdin, stdout, stderr, wait_thr|
          exit_code = wait_thr.value
          result = stdout.read
          puts result if exit_code != 0
          expect(wait_thr.value).to be_success
          expect(result).to include("net-procfile")
          expect(result).to_not include("console")
        end
      end
    end
  end

  def with_memory_limit(memory_limit)
    previous_value = ENV['MEMORY_LIMIT']
    begin
      ENV['MEMORY_LIMIT'] = memory_limit
      yield
    ensure
      ENV['MEMORY_LIMIT'] = previous_value
    end
  end

end