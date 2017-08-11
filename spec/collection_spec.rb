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

require "minitest/autorun"

require "senkyoshi"
require "pry"

require_relative "helpers.rb"
require_relative "mocks/mockzip"

include Senkyoshi

describe Senkyoshi do
  describe "Collection" do
    before do
      @collection = Senkyoshi::Collection.new
    end

    describe "initialize" do
      it "sets up an empty collection" do
        assert_equal(@collection.resources, [])
      end
    end

    describe "add" do
      it "adds resources to its collection" do
        @collection.add([Senkyoshi::Resource.new])
        assert_equal(@collection.resources.length, 1)

        @collection.add([Senkyoshi::Resource.new])
        assert_equal(@collection.resources.length, 2)
      end
    end

    describe "detect_xid" do
      it "should detect the resources with matching xid" do
        xid = "xid-1234_1"
        path = "fake/path/to/file__#{xid}.txt"
        entry = MockZip::MockEntry.new(path)
        file = Senkyoshi::SenkyoshiFile.new(entry)
        resource = Senkyoshi::Resource.new
        @collection.add([file, resource])
        assert_equal(@collection.detect_xid(xid), file)
      end
    end
  end
end
