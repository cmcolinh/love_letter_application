# frozen_string_literal: true

require 'dry-initializer'

module LoveLetterApplication
  module Actions
    class Priestess
      include Dry::Initializer.define -> do
        option :play_card, type: ::Types::Callable
        option :get_card_played_node, type: ::Types::Callable
        option :make_player_not_targetable, ::Types::Callable
        option :get_player_not_targetable_node, type: ::Types::Callable
        option :process_next_player_turn, type: ::Types::Callable
      end

      def call(game_board:, change_orders:)
        game_board = play_card.(
          game_board: game_board,
          card_id: Priestess::id)
        game_board = make_player_not_targetable.(
          game_board: game_board,
          player_id: game_board.current_player_id.to_i)
        change_orders = change_orders.push(get_card_played_node.(
          player_id: game_board.current_player_id.to_i,
          card_id: Priestess::id))
        process_next_player_turn.(
          game_board: game_board,
          change_orders: change_orders.push(get_player_not_targetable_node.(
            player_id: game_board.current_player_id.to_i)))
      end

      def self.id;4;end
    end
  end
end

