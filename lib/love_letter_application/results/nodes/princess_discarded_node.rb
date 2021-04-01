# frozen_string_literal: true

require 'dry-struct'

module LoveLetterApplication
  module Results
    module Nodes
      class PrincessDiscardedNode < Dry::Struct
        attribute :player_id, ::Types::Strict::Integer

        def accept(visitor, **args)
          visitor = ::Types.Interface(:handle_princess_discarded).call(visitor)
          visitor.handle_princess_discarded(self, args)
        end
      end
    end
  end
end

