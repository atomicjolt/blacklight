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

require "senkyoshi/models/resource"

module Senkyoshi
  class Module < Resource
    attr_accessor :module_items

    def initialize(title, identifier)
      @identifier = identifier
      @title = title
      @module_items = []
    end

    def self.find_module_from_item_id(modules, id)
      modules.detect do |mod|
        mod.module_items.detect { |item| item.identifierref == id }
      end
    end

    def canvas_conversion(*)
      CanvasCc::CanvasCC::Models::CanvasModule.new.tap do |cc_module|
        cc_module.identifier = @identifier
        cc_module.title = @title
        cc_module.workflow_state = "published"
        cc_module.module_items = @module_items
      end
    end
  end
end
