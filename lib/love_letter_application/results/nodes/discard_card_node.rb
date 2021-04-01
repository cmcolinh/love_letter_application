# frozen_string_literal: true

require 'dry-struct'

module LoveLetterApplication
  module Results
    module Nodes
      class DiscardCardNode < Dry::Struct
        attribute :player_id, ::Types::Strict::Integer
        attribute :card_id, ::Types::Strict::Integer

        def accept(visitor, **args)
          visitor = ::Types.Interface(:handle_discard_card).call(visitor)
          visitor.handle_discard_card(self, args)
        end
      end
    end
  end
end

