# frozen_string_literal: true

require 'dry-initializer'

module LoveLetterApplication
  module Results
    class ProcessRoundCompleteByElimination
      extend Dry::Initializer
      option :log_all_opponents_eliminated_node, type: ::Types.Interface(:accept), reader: :private
      option :get_player_victory_node, type: ::Types::Callable, reader: :private
      option :round_complete, type: ::Types::Callable, reader: :private
      option :get_result_game_board_node, type: ::Types::Callable, reader: :private

      def call(game_board:, player:, change_orders:)
        game_board = round_complete.call(
          game_board: game_board,
          victorious_player_id: [player.id.to_i])
        change_orders
          .push(log_all_opponents_eliminated_node)
          .push(get_player_victory_node.(player_id: [player.id]))
          .push(get_result_game_board_node.(game_board: game_board))
      end
    end
  end
end

