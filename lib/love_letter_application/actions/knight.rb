# frozen_string_literal: true

require 'dry-initializer'

module LoveLetterApplication
  module Actions
    class Knight
      include Dry::Initializer.define -> do
        option :play_card, type: ::Types::Callable
        option :get_card_played_node, type: ::Types::Callable
        option :process_knight_showdown, type: ::Types::Callable
      end

      def call(target_player_id:, game_board:, change_orders:)
        game_board = play_card.(
          game_board: game_board,
          card_id: Knight::id)
        change_orders = change_orders.push(get_card_played_node.(
          player_id: game_board.current_player_id.to_i,
          card_id: Knight::id))
        process_knight_showdown.(
          target_player_id: target_player_id.to_i,
          game_board: game_board,
          change_orders: change_orders)
      end

      def self.id;3;end
    end
  end
end

