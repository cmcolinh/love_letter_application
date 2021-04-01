# frozen_string_literal: true

require 'dry-initializer'

module LoveLetterApplication
  module Actions
    class Princess
      include Dry::Initializer.define -> do
        option :play_card, type: ::Types::Callable
        option :get_card_played_node, type: ::Types::Callable
        option :get_princess_discarded_node, type: ::Types::Callable
        option :eliminate_player, type: ::Types::Callable
      end

      def call(game_board:, change_orders:)
        game_board = play_card.(game_board: game_board, card_id: Princess::id)
        eliminate_player.(
          target_player_id: game_board.current_player_id.to_i,
          game_board: game_board,
          change_orders: change_orders
            .push(get_card_played_node(
              player_id: game_board.current_player_id.to_i,
              card_id: Princess::id)
            .push(get_princess_discarded_node.(
              player_id: game_board.current_player_id.to_i))))
      end

      def self.id;8;end
    end
  end
end

