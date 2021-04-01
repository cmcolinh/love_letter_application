# frozen_string_literal: true

require 'dry-initializer'

module LoveLetterApplication
  module Results
    class ProcessDrawAfterDiscard
      include Dry::Initializer.define -> do
        option :get_drawn_card_node, type: ::Types::Callable
        option :discard_and_draw, ::Types::Callable
        option :process_next_player_turn, ::Types::Callable
      end

      def call(target_player_id:, game_board:, change_orders:)
        drawn_card_id = game_board.draw_pile.first&.id&.to_i || set_aside_card.id.to_i
        game_board = discard_and_draw.(game_board: game_board, player_id: target_player_id)
        process_next_player_turn.(
          game_board: game_board,
          change_orders: change_orders.push(get_drawn_card_node.(
            player_id: target_player_id,
            card_id: drawn_card_id)))
      end
    end
  end
end

