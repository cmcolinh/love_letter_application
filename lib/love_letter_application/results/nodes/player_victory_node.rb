# frozen_string_literal: true

require 'dry-initializer'

module LoveLetterApplication
  module Results
    module Nodes
      class PlayerVictoryNode
        extend Dry::Initializer
        option :player_id, type: ::Types::Array::of(::Types::Strict::Integer)

        def accept(visitor, **args)
          visitor = ::Types.Interface(:handle_player_victory).call(visitor)
          visitor.handle_player_victory(self, **args)
        end
      end
    end
  end
end

