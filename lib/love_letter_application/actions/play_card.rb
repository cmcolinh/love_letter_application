# frozen_string_literal: true

require 'dry-initializer'

module LoveLetterApplication
  module Actions
    class PlayCard
      extend Dry::Initializer
      option :get_played_card_node, type: ::Types.Interface(:call)
      oprion :get_game_board_with_played_card, type: ::Types.Interface(:call)
      option :resolve_card_action_for, type: ::Types::Array::of(::Types.Interface(:call))
      def call(**args)
        card_id = args[:card_id].to_i
        change_orders = args[:change_orders]
        game_board = args[:game_board]
        player_id = game_board.current_player_id.to_i
        change_orders = change_orders.push(
          get_played_card_node.(
            player_id: player_id,
            card_id: card_id))
        game_board = get_game_board_with_played_card.(
          game_board: game_board,
          player_id: player_id,
          card_id: card_id)
        new_args = args.reject{|k, v| [:change_orders, :game_board].include?(k)}
        new_args[:change_orders] = change_orders
        new_args[:game_board] = game_board
        resolve_card_action_for[card_id].(new_args)
      end
    end
  end
end

