# frozen_string_literal: true

require 'dry-initializer'

module LoveLetterApplication
  module Results
    class ProcessCorrectGuess
      include Dry::Initializer.define -> do
        option :log_correct_guess_node, type: ::Types.Interface(:accept), reader: :private
        option :eliminate_player, type: ::Types::Callable, reader: :private
      end

      def call(target_player_id:, game_board:, change_orders:)
        eliminate_player.(
          target_player_id: target_player_id,
          game_board: game_board,
          change_orders: change_orders.push(log_correct_guess_node))
      end
    end
  end
end

