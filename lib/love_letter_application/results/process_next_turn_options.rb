# frozen_string_literal: true

require 'dry-initializer'

module LoveLetterApplication
  module Results
    class ProcessNextTurnOptions
      extend Dry::Initializer
      option :get_legal_card_ids, type: ::Types::Callable
      option :all_card_validator_builders, type: ::Types::ArrayOfCallable
      option :get_play_card_with_no_options_node, ::Types::Callable
      option :get_play_card_with_player_id_option_node, type: ::Types::Callable
      option :get_play_card_with_player_id_and_card_id_option_node, type: ::Types::Callable
      
      def call(game_board:, change_orders:)
        current_player_id = game_board.current_player_id.to_i
        hand = game_board.players
          .find{|player| player.id.to_i.eql?(current_player_id)}
          .hand
        card_ids = get_legal_card_ids.(card_list: hand)
        card_ids.each do |card_id|
          change_orders = change_orders.push(get_node_for(game_board, card_id))
        end
        change_orders
      end

      def get_node_for(game_board, card_id)
        build_validator = all_card_validator_builders[card_id]
        validator = build_validator.(game_board)
        # a handler will be called by validator#accept based on the type of the validator found
        validator.accept(self, card_id: card_id)
      end

      def handle_no_options_validator(validator, card_id:)
        get_play_card_with_no_options_node.(card_id: card_id)
      end

      def handle_select_player_id_validator(validator, card_id:)
        get_play_card_with_player_id_option_node.(
          card_id: card_id,
          player_id_list: validator.legal_target_player_ids)
      end

      def handle_soldier_validator(validator, card_id:)
        get_play_card_with_player_id_and_card_id_option_node.(
          card_id: card_id,
          player_id_list: validator.legal_target_player_ids,
          card_id_list: validator.legal_target_card_ids)
      end
    end
  end
end

