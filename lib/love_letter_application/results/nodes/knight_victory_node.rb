# frozen_string_literal: true

require 'dry-struct'

module LoveLetterApplication
  module Results
    module Nodes
      class KnightVictoryNode < Dry::Struct
        attribute :winning_player_id, ::Types::Strict::Integer
        attribute :losing_player_id, ::Types::Strict::Integer

        def accept(visitor, **args)
          visitor = ::Types.Interface(:handle_knight_victory).call(visitor)
          visitor.handle_knight_victory(self, args)
        end
      end
    end
  end
end

