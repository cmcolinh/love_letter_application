#frozen string_literal: true

require 'dry-initializer'

module LoveLetterApplication
  module Validator
    class PlayCard
      extend Dry::Initializer
      option :validate_card_id, type: ::Types::Callable
      option :full_validator_for, type: ::Types::Hash

      def call(action_hash)
        result = validate_card_id.(action_hash)
        return result if result.failure?
        validate = full_validator_for[result[:card_id]]
        validate.(action_hash)
      end
    end
  end
end

