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
require "senkyoshi/models/content_file"

module Senkyoshi
  class CourseToc
    def self.get_pre_data(xml, file_name)
      target_type = xml.xpath("/COURSETOC/TARGETTYPE/@value").first.text
      if target_type != "MODULE" || target_type != "DIVIDER"
        title = xml.xpath("/COURSETOC/LABEL/@value").first.text
        internal_handle = xml.xpath("/COURSETOC/INTERNALHANDLE/@value").
          first.text
        {
          title: title,
          target_type: target_type,
          original_file: file_name,
          internal_handle: internal_handle,
        }
      end
    end
  end
end
