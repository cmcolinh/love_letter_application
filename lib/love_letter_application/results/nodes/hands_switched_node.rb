# frozen_string_literal: true

require 'dry-struct'

module LoveLetterApplication
  module Results
    module Nodes
      class HandsSwitchedNode < Dry::Struct
        attribute :player_id, ::Types::Strict::Integer
        attribute :target_player_id, ::Types::Strict::Integer
        attribute :card_id_given, ::Types::Strict::Integer
        attribute :card_id_taken, ::Types::Strict::Integer

        def accept(visitor, **args)
          visitor = ::Types.Interface(:handle_hands_switched).call(visitor)
          visitor.handle_hands_switched(self, args)
        end
      end
    end
  end
end

