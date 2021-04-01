#frozen string_literal: true

require 'dry-initializer'

module LoveLetterApplication
  class Validator
    class Base
      extend Dry::Initializer
      option :validate_input, type: Types.Interface(:call)
      option :wrap_result, type: Types.Interface(:call)

      def call(action_hash)
        result = validate_input.(action_hash)
        return result if result.failure?
        wrap_result.(result)
    end
  end
end

