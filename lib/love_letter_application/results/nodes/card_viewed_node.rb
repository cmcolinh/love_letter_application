# frozen_string_literal: true

require 'dry-struct'

module LoveLetterApplication
  module Results
    module Nodes
      class CardViewedNode < Dry::Struct
        attribute :player_id, ::Types::Strict::Integer
        attribute :target_player_id, ::Types::Strict::Integer
        attribute :card_id, ::Types::Strict::Integer

        def accept(visitor, **args)
          visitor = ::Types.Interface(:handle_card_viewed).call(visitor)
          visitor.handle_card_viewed(self, **args)
        end
      end
    end
  end
end

