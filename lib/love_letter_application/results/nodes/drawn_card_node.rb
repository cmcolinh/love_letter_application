# frozen_string_literal: true

require 'dry-struct'

module LoveLetterApplication
  module Results
    module Nodes
      class DrawnCardNode < Dry::Struct
        attribute :player_id, ::Types::Strict::Integer
        attribute :card_id, ::Types::Strict::Integer

        def accept(visitor, **args)
          visitor = ::Types.Interface(:handle_drawn_card).call(visitor)
          visitor.handle_drawn_card(self, args)
        end
      end
    end
  end
end

