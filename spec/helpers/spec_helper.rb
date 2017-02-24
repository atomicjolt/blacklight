# Copyright (C) 2016, 2017 Atomic Jolt

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require "webmock/minitest"
WebMock.disable_net_connect!(allow_localhost: true)

def fixture_finder(name)
  File.join(File.dirname(__FILE__), "..", "fixtures", name)
end

def stub_toe(type, pattern, json, with_params = nil)
  request = stub_request(type, pattern).
    to_return(
      status: 200,
      body: json,
      headers: { content_type: "json" },
    )
  if with_params
    request.with(with_params)
  end
end

def stub_active_courses_in_account(json)
  stub_toe(:get, /v1\/accounts\/.+\/courses/, json)
end
