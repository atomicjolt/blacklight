describe "RootResource" do
  before do
    @xml = get_fixture_xml "content.xml"
    @id = "res001"
    @pre_data = { file_name: @id }
  end

  it "should implement from method" do
    result = RootResource.from(@xml, @pre_data)

    assert_equal(result.id, @id)
  end
end
