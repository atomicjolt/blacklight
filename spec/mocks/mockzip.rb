class MockZip
  class MockEntry
    attr_reader(:name, :ftype)
    def initialize(name = "fake/path__xid-12.jpg", ftype = :file)
      @name = name
      @ftype = ftype
    end

    def extract(dummy = nil)
    end
  end

  def initialize(entries = nil)
    @entries = entries || [MockEntry.new, MockEntry.new, MockEntry.new]
  end

  def entries
    @entries
  end

  def glob(*)
    entries
  end
end
