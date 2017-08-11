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

module Senkyoshi
  class Collection
    attr_reader :resources

    def initialize(resources = [])
      @resources = resources
    end

    def add(resources)
      @resources.concat(resources)
    end

    def detect_xid(xid)
      @resources.detect do |resource|
        resource.matches_xid? xid
      end
    end

    def find_by_id(id)
      @resources.detect { |item| item.respond_to?(:id) && item.id == id }
    end

    def find_instances_of(class_name)
      @resources.select { |res| res.class == class_name }
    end

    def find_instances_not_of(types)
      @resources.select do |res|
        types.each { |type| res.class != type }
      end
    end

    def each
      @resources.each do |resource|
        yield resource
      end
      self
    end
  end
end
