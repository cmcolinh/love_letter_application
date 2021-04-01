#frozen string_literal: true

require 'dry-validation'

module LoveLetterApplication
  module Validator
    class ValidateCardId < Dry::Validation::Contract
      option :legal_card_ids, type: ::Types::Array.of(::Types::Coercible::Integer)
      
      params do
        required(:player_action).filled(:string, eql?: 'play_card')
        required(:card_id).filled(:integer)
      end

      rule(:card_id) do
        if !legal_card_ids.include?(values[:card_id])
          key.failure({text: "card_id '#{values[:card_id]}' is not permitted", status: 400})
        end
      end
    end
  end
end

