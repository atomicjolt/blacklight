class MockZip
  class MockEntry
    attr_accessor(:name)
    def initialize(name = "fake/path__xid-12.jpg")
      @name = name
    end
  end

  def initialize(entries = nil)
    @entries = entries || [MockEntry.new, MockEntry.new, MockEntry.new]
  end

  def entries
    @entries
  end
end
