# frozen_string_literal: true

require 'dry-struct'

module LoveLetterApplication
  module Results
    module Nodes
      class PlayCardWithPlayerIdOptionNode < Dry::Struct
        attribute :card_id, ::Types::Strict::Integer
        attribute :player_id_list, ::Types::ArrayOfStrictInteger

        def accept(visitor, **args)
          visitor = ::Types.Interface(:handle_play_card_with_player_id_option).call(visitor)
          visitor.handle_play_card_with_player_id_option(self, args)
        end
      end
    end
  end
end

