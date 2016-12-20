def get_fixture(name)
  File.open("#{File.dirname(__FILE__)}/fixtures/#{name}") do |file|
    yield file
  end
end

def get_zip_fixture(name)
  Zip::File.open("#{File.dirname(__FILE__)}/fixtures/#{name}") do |file|
    yield file
  end
end

def get_zip_manifest(name)
  get_zip_fixture(name) do |file|
    yield file, get_manifest_entry(file)
  end
end

def get_fixture_xml(name)
  get_fixture(name) do |file|
    Nokogiri::XML(file)
  end
end
