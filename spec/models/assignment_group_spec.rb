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

include Senkyoshi

describe Senkyoshi do
  describe "AssignmentGroup" do
    before do
      @title = "Group Title"
      @group_id = SecureRandom.hex
      @assignment_group = AssignmentGroup.new(@title, @group_id)
    end

    describe "initialize" do
      it "should initialize assignment_group" do
        assert_equal (@assignment_group.is_a? Object), true
      end

      it "should initialize with parameters" do
        assert_equal (@assignment_group.instance_variable_get :@title), @title
        assert_equal (@assignment_group.
          instance_variable_get :@id), @group_id
      end
    end

    describe "canvas_conversion" do
      it "should create a canvas assignment_group" do
        result = @assignment_group.canvas_conversion
        assert_equal(
          result.class, CanvasCc::CanvasCC::Models::AssignmentGroup
        )
      end

      it "should create a canvas assignment_group with correct details" do
        result = @assignment_group.canvas_conversion
        assert_equal result.title, @title
        assert_equal result.identifier, @group_id
      end
    end
  end
end
