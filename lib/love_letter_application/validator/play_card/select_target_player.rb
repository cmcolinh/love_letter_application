#frozen string_literal: true

require 'dry-validation'

module LoveLetterApplication
  module Validator
    class PlayCard
      class SelectTargetPlayer < Dry::Validation::Contract
        option :legal_target_player_ids, type: ::Types::Array.of(::Types::Coercible::Integer)

        params do
          required(:target_player_id).filled(:integer)
        end

        rule(:target_player_id) do
          if !legal_target_player_ids.include?(values[:target_player_id])
            key.failure({text: "target_player_id '#{values[:target_player_id]}' is not permitted",
              status: 422})
          end
        end

        def accept(visitor, **args)
          visitor = ::Types.Interface(:handle_select_player_id_validator).call(visitor)
          visitor.handle_select_player_id_validator(self, args)
        end
      end
    end
  end
end

