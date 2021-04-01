# frozen_string_literal: true

require 'dry-initializer'

module LoveLetterApplication
  module Actions
    class Soldier
      include Dry::Initializer.define -> do
        option :play_card, type: ::Types::Callable
        option :get_card_played_node, type: ::Types::Callable
        option :process_correct_guess, type: ::Types::Callable
        option :process_incorrect_guess, type: ::Types::Callable
      end
      
      def call(target_player_id:, target_card_id:, game_board:, change_orders:)
        game_board = play_card.call(
          game_board: game_board,
          card_id: Soldier::id)
        change_orders = change_orders.push(get_card_played_node.(
          player_id: game_board.current_player_id.to_i,
          card_id: Soldier::id))
        if guess_is_correct?(target_player_id, target_card_id, game_board)
          process_correct_guess.(
            target_player_id: target_player_id,
            game_board: game_board,
            change_orders: change_orders)
        else
          process_incorrect_guess.(
            game_board: game_board,
            change_orders: change_orders)
        end
      end

      def self.id;1;end

      private
      def guess_is_correct?(target_player_id, target_card_id, game_board)
        game_board
          .players
          .find{|player| player.id.to_i.eql?(target_player_id)}
          .hand
          .any?{|card| card.id.to_i.eql?(target_card_id)}
      end
    end
  end
end

