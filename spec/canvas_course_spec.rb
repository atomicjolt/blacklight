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
require "senkyoshi/canvas_course"
require_relative "helpers/spec_helper"
require_relative "mocks/mock_client.rb"

include Senkyoshi

describe Senkyoshi::CanvasCourse do
  describe "metadata_from_file" do
    it "should return metadata" do
      file = fixture_finder("bfcoding-101-export.imscc")
      metadata = Senkyoshi::CanvasCourse.metadata_from_file(file)
      assert_equal metadata, name: "bfcoding 101"
    end
  end

  describe "from_metadata" do
    it "should return a canvas course" do
      name = "bfcoding 101"
      CanvasCourse.stub(:client, MockClient.new) do
        metadata = { name: name }
        course = Senkyoshi::CanvasCourse.from_metadata(metadata)
        assert_kind_of Senkyoshi::CanvasCourse, course
      end
    end
  end

  describe "create_scorm_assignments" do
    it "should not call upload for nil package" do
      subject = CanvasCourse.new(nil, nil, nil)
      assert_equal(
        subject.create_scorm_assignments([nil], "fake_id", false), [nil]
      )
    end
  end
end
