# frozen_string_literal: true

require 'dry-initializer'

module LoveLetterApplication
  module Results
    class ProcessPrincessDiscarded
      include Dry::Initializer.define -> do
        option :get_princess_discarded_node, type: ::Types::Callable
        option :eliminate_player, type: ::Types::Callable
      end

      def call(target_player_id:, game_board:, change_orders:)
        eliminate_player.(
          target_player_id: target_player_id,
          game_board: game_board,
          change_orders: change_orders.push(
            get_princess_discarded_node.(player_id: target_player_id)))
      end
    end
  end
end

