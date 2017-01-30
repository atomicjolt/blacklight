module Senkyoshi
  class Collection
    attr_reader :resources

    def initialize(resources = [])
      @resources = resources
    end

    def add(resources)
      @resources.concat(resources)
    end

    def detect_xid(xid)
      @resources.detect do |resource|
        resource.matches_xid? xid
      end
    end

    def find_by_id(id)
      @resources.detect { |item| item.respond_to?(:id) && item.id == id }
    end

    def find_instances_of(class_name)
      @resources.select { |res| res.class == class_name }
    end

    def find_instances_not_of(types)
      @resources.select do |res|
        types.each { |type| res.class != type }
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
