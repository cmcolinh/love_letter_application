# frozen_string_literal: true

require 'dry-struct'

module LoveLetterApplication
  module Results
    module Nodes
      class EliminatedPlayerNode < Dry::Struct
        attribute :player_id, ::Types::Strict::Integer

        def accept(visitor, **args)
          visitor = ::Types.Interface(:handle_eliminated_player).call(visitor)
          visitor.handle_eliminated_player(self, args)
        end
      end
    end
  end
end

