# frozen_string_literal: true

require 'dry-initializer'

module LoveLetterApplication
  module Results
    class ProcessSwitchHands
      include Dry::Initializer.define -> do
        option :get_hands_switched_node, type: ::Types::Callable
        option :switch_hands, type: ::Types::Callable
        option :process_next_player_turn, type: ::Types::Callable
      end

      def call(target_player_id:, game_board:, change_orders:)
        player_id = game_board.current_player_id.to_i
        old_card_id, new_card_id = get_cards_held_by(player_id, target_player_id.to_i, game_board)
        game_board = switch_hands.(
          player_id: player_id,
          target_player_id: target_player_id,
          game_board: game_board)
        process_next_player_turn.(
          game_board: game_board,
          change_orders: change_orders.push(get_hands_switched_node.(
            player_id: player_id,
            target_player_id: target_player_id,
            card_id_given: old_card_id,
            card_id_taken: new_card_id)))
      end

      private
      def get_cards_held_by(player_id, target_player_id, game_board)
        old_card_id = game_board.players
          .find{|player| player.id.to_i.eql?(player_id)}
          .hand
          .first
          .id
          .to_i

        new_card_id = game_board.players
          .find{|player| player.id.to_i.eql?(target_player_id)}
          .hand
          .first
          .id
          .to_i

        [old_card_id, new_card_id]
      end
    end
  end
end

