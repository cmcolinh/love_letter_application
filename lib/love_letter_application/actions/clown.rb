# frozen_string_literal: true

require 'dry-initializer'

module LoveLetterApplication
  module Actions
    class Clown
      include Dry::Initializer.define -> do
        option :play_card, type: ::Types::Callable
        option :get_card_played_node, type: ::Types::Callable
        option :get_card_viewed_node, type: ::Types::Callable
        option :process_next_player_turn, type: ::Types::Callable
      end

      def call(target_player_id:, game_board:, change_orders:)
        game_board = play_card.(
          game_board: game_board,
          card_id: Clown::id)
        change_orders = change_orders.push(get_card_played_node.(
          player_id: game_board.current_player_id.to_i,
          card_id: Clown::id))
        process_next_player_turn.(
          game_board: game_board,
          change_orders: change_orders.push(get_card_viewed_node.(
            player_id: game_board.current_player_id.to_i,
            target_player_id: target_player_id.to_i,
            card_id: get_card_id(game_board, target_player_id.to_i))))

      end

      def self.id;2;end

      private
      def get_card_id(game_board, target_player_id)
        game_board.players
          .find{|player| player.id.to_i.eql?(target_player_id)}
          .hand
          .first
          .id
          .to_i
      end
    end
  end
end

