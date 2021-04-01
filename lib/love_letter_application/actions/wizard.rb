# frozen_string_literal: true

require 'dry-initializer'

module LoveLetterApplication
  module Actions
    class Wizard
      include Dry::Initializer.define -> do
        option :play_card, type: ::Types::Callable
        option :get_card_played_node, type: ::Types::Callable
        option :process_resolve_wizard, type: ::Types::Callable
      end

      def call(target_player_id:, game_board:, change_orders:)
        game_board = play_card.(
          game_board: game_board,
          card_id: Wizard::id)
        change_orders = change_orders.push(get_card_played_node.(
          player_id: game_board.current_player_id.to_i,
          card_id: Wizard::id))
        process_resolve_wizard.(
          target_player_id: target_player_id.to_i,
          game_board: game_board,
          change_orders: change_orders)
      end

      def self.id;5;end
    end
  end
end

