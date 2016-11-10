module Exceptions

	class BadFileNameError < StandardError

		def initialize(msg='Bad File Name')
			super(msg)
		end

	end

end