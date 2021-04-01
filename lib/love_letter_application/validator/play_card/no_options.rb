#frozen string_literal: true

require 'dry-validation'

module LoveLetterApplication
  module Validator
    class PlayCard
      class NoOptions < Dry::Validation::Contract
        params{}

        def accept(visitor, **args)
          visitor = ::Types.Interface(:handle_no_options_validator).call(visitor)
          visitor.handle_no_options_validator(self, args)
        end
      end
    end
  end
end
 
