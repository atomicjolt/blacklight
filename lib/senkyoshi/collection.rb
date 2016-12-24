module Senkyoshi
  class Collection
    attr_reader :resources

    def initialize
      @resources = []
    end

    def add(resources)
      @resources.concat(resources)
    end

    def detect_xid(xid)
      @resources.detect do |resource|
        resource.matches_xid? xid
      end
    end

    def each
      @resources.each do |resource|
        yield resource
      end
      self
    end
  end
end
