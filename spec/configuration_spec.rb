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

describe Senkyoshi do
  describe Configuration do
    describe "#canvas_url" do
      it "default value is nil" do
        Configuration.stub(:_config, {}) do
          canvas_url = Configuration.new.canvas_url
          assert_nil canvas_url
        end
      end
    end

    describe "#canvas_url=" do
      it "can set value" do
        config = Configuration.new
        config.canvas_url = "bfcoder.com"
        assert_equal(config.canvas_url, "bfcoder.com")
      end
    end

    describe "#canvas_token" do
      it "default value is nil" do
        Configuration.stub(:_config, {}) do
          canvas_token = Configuration.new.canvas_token
          assert_nil canvas_token
        end
      end
    end

    describe "#canvas_token=" do
      it "can set value" do
        config = Configuration.new
        config.canvas_token = "token"
        assert_equal(config.canvas_token, "token")
      end
    end

    describe "#account_id" do
      it "default value is :self" do
        Configuration.stub(:_config, {}) do
          account_id = Configuration.new.account_id
          assert_equal account_id, :self
        end
      end
    end

    describe "#account_id=" do
      it "can set value" do
        config = Configuration.new
        config.account_id = 42
        assert_equal(config.account_id, 42)
      end
    end

    describe "#scorm_url" do
      it "default value is nil" do
        Configuration.stub(:_config, {}) do
          scorm_url = Configuration.new.scorm_url
          assert_nil scorm_url
        end
      end
    end

    describe "#scorm_url=" do
      it "can set value" do
        config = Configuration.new
        config.scorm_url = "bfcoder.com"
        assert_equal(config.scorm_url, "bfcoder.com")
      end
    end

    describe "#scorm_launch_url" do
      it "default value is nil" do
        Configuration.stub(:_config, {}) do
          scorm_launch_url = Configuration.new.scorm_launch_url
          assert_nil scorm_launch_url
        end
      end
    end

    describe "#scorm_launch_url=" do
      it "can set value" do
        config = Configuration.new
        config.scorm_launch_url = "bfcoder.com"
        assert_equal(config.scorm_launch_url, "bfcoder.com")
      end
    end

    describe "#scorm_shared_auth" do
      it "default value is nil" do
        Configuration.stub(:_config, {}) do
          scorm_shared_auth = Configuration.new.scorm_shared_auth
          assert_nil scorm_shared_auth
        end
      end
    end

    describe "#scorm_shared_auth=" do
      it "can set value" do
        config = Configuration.new
        config.scorm_shared_auth = "12345"
        assert_equal(config.scorm_shared_auth, "12345")
      end
    end

    describe "#request_timeout" do
      it "default value is 1800 (30 mins)" do
        Configuration.stub(:_config, {}) do
          request_timeout = Configuration.new.request_timeout
          assert_equal request_timeout, 1800
        end
      end
    end

    describe "#request_timeout=" do
      it "can set value" do
        config = Configuration.new
        config.request_timeout = "12345"
        assert_equal(config.request_timeout, "12345")
      end
    end
  end
end
