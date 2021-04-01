#frozen string_literal: true

require 'dry-initializer'
require 'game_validator/validator/validate_to_action'

module LoveLetterApplication
  module Validator
    class PlayCard
      class Builder
        extend Dry::Initializer
        option :build_raw_validator, type: ::Types::Callable
        option :wrap_result, type: ::Types::Callable

        def call(model)
          GameValidator::Validator::ValidateToAction::new(
            validate: build_raw_validator.(model),
            wrap: wrap_result)
        end
      end
    end
  end
end

