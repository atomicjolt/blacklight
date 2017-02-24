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

class MockZip
  class MockEntry
    attr_reader(:name, :ftype)
    def initialize(name = "fake/path__xid-12.jpg", ftype = :file)
      @name = name
      @ftype = ftype
    end

    def file?
      true
    end

    def extract(dummy = nil) end

    def file_path(*)
      @name
    end
  end

  def initialize(entries = nil)
    @entries = entries || [MockEntry.new, MockEntry.new, MockEntry.new]
  end

  def entries
    @entries
  end

  def name
    "MockZip"
  end

  def glob(*)
    entries
  end
end
