# frozen_string_literal: true

require 'dry-initializer'

module LoveLetterApplication
  module Results
    class ProcessIncorrectGuess
      extend Dry::Initializer
      option :log_incorrect_guess_node, type: ::Types.Interface(:accept)
      option :process_next_player_turn, type: ::Types::Callable

      def call(game_board:, change_orders:)
        process_next_player_turn.(
          game_board: game_board,
          change_orders: change_orders.push(log_incorrect_guess_node))
      end
    end
  end
end

