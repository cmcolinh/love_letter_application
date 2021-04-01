# frozen_string_literal: true

require 'dry-initializer'

module LoveLetterApplication
  module Results
    class ProcessResolveWizard
      include Dry::Initializer.define -> do
        option :get_discard_card_node, type: ::Types::Callable
        option :process_discard_passive_result, type: ::Types::ArrayOfCallable
        option :process_draw_after_discard, type: ::Types::Callable
      end

      def call(target_player_id:, game_board:, change_orders:)
        card_id = card_id_for(game_board, target_player_id)
        process_discard_passive_result[card_id].(
          target_player_id: target_player_id,
          game_board: game_board,
          change_orders: change_orders
            .push(get_discard_card_node.(player_id: target_player_id, card_id: card_id)),
          &process_draw_after_discard.method(:call))
      end

      private
      def card_id_for(game_board, player_id)
        game_board.players
          .find{|player| player.id.to_i.eql?(player_id.to_i)}
          .hand
          .first
          .id
          .to_i
      end
    end
  end
end

