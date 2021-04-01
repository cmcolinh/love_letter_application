#frozen string_literal: true

require 'dry-validation'

module LoveLetterApplication
  module Validator
    class PlayCard
      class Soldier < Dry::Validation::Contract
        option :legal_target_player_ids, type: ::Types::Array.of(::Types::Coercible::Integer)
        option :legal_target_card_ids, type: ::Types::Array.of(::Types::Coercible::Integer)

        params do
          required(:target_player_id).filled(:integer)
          required(:target_card_id).filled(:integer)
        end

        rule(:target_player_id) do
          if !legal_card_ids.include?(values[:target_player_id])
            key.failure({text: "target_player_id '#{values[:target_player_id]}' is not permitted",
              status: 422})
          end
        end

        rule(:target_card_id) do
          if !legal_card_ids.include?(values[:target_card_id])
            key.failure({text: "target_card_id '#{values[:target_card_id]}' is not permitted",
              status: 422})
          end
        end

        def accept(visitor, **args)
          visitor = ::Types.Interface(:handle_soldier_validator).call(visitor)
          visitor.handle_soldier_validator(self, args)
        end
      end
    end
  end
end

