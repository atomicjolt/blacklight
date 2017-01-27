require "minitest/autorun"
require "senkyoshi"
require "pry"

require_relative "../../lib/senkyoshi/models/link"

include Senkyoshi

describe Senkyoshi do
  describe "get_pre_data" do
    it "should return the correct data" do
      link_xml = get_fixture_xml "link.xml"
      link_pre_data = Link.get_pre_data(link_xml, nil)

      assert_equal("/Content/Test Test", link_pre_data[:title])
      assert_equal("res00053", link_pre_data[:referrer])
      assert_equal("res00030", link_pre_data[:referred_to])
    end
  end
end
