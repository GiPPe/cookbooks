#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

provides "cpu"

total = 0
real = 0

File.open("/proc/cpuinfo").each do |line|
  case line
  when /processor\s+:\s(.+)/
    total += 1
  when /physical id\s+:\s(.+)/
    real += 1
  end
end

cpu Mash.new
cpu[:total] = total
cpu[:real] = real
