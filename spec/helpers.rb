def get_fixture(name)
  File.read("#{File.dirname(__FILE__)}/fixtures/#{name}")
end

def get_fixture_xml(name)
  Nokogiri::XML(get_fixture(name))
end
