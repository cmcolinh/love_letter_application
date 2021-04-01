# frozen_string_literal: true

require 'dry-struct'

module LoveLetterApplication
  module Results
    module Nodes
      class PlayCardWithNoOptionsNode < Dry::Struct
        attribute :card_id, ::Types::Strict::Integer

        def accept(visitor, **args)
          visitor = ::Types.Interface(:handle_play_card_with_no_options).call(visitor)
          visitor.handle_play_card_with_no_options(self, args)
        end
      end
    end
  end
end

