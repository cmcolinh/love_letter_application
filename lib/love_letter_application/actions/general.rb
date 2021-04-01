# frozen_string_literal: true

require 'dry-initializer'

module LoveLetterApplication
  module Actions
    class General
      include Dry::Initializer.define -> do
        option :play_card, type: ::Types::Callable
        option :get_card_played_node, type: ::Types::Callable
        option :process_switch_hands, type: ::Types::Callable
      end

      def call(target_player_id:, game_board:, change_orders:)
        game_board = play_card.(game_board: game_board, card_id: General::id)
        change_orders = change_orders.push(get_card_played_node.(
          player_id: game_board.current_player_id.to_i,
          card_id: General::id))
        process_switch_hands.(
          target_player_id: target_player_id,
          game_board: game_board,
          change_orders: change_orders)
      end

      def self.id;6;end
    end
  end
end

