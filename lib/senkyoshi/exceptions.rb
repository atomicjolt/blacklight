module Exceptions
  class BadFileNameError < StandardError
    def initialize(msg = "Bad File Name")
      super(msg)
    end
  end

  class MissingFileError < StandardError
    def initialize(msg = "Couldn't find file")
      super(msg)
    end
  end

  class BadResponse < StandardError
    def initialize(msg = "Bad Response")
      super(msg)
    end 
  end 
end
