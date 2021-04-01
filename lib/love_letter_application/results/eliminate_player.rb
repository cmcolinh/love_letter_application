# frozen_string_literal: true

require 'dry-initializer'

module LoveLetterApplication
  module Results
    class EliminatePlayer
      extend Dry::Initializer
      option :process_round_complete_by_elimination, type: ::Types::Callable
      option :eliminate_player_from_game_board, ::Types::Callable
      option :process_next_player_turn, type: ::Types::Callable
      option :get_eliminated_player_node, type: ::Types::Callable

      def call(target_player_id:, game_board:, change_orders:)
        change_orders = change_orders
          .push(get_eliminated_player_node.(player_id: target_player_id))
        game_board = eliminate_player_from_game_board.(
          game_board: game_board,
          player_id: target_player_id)
        if one_player_remaining?(game_board)
          process_round_complete_by_elimination.(
            game_board: game_board,
            change_orders: change_orders,
            player: game_board
              .players
              .find(&:active?))
        else
          process_next_player_turn.(game_board: game_board, change_orders: change_orders)
        end
      end

      private
      def one_player_remaining?(game_board)
        game_board
          .players
          .select(&:active?)
          .length
          .eql?(1)
      end
    end
  end
end

