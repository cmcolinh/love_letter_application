# frozen_string_literal: true:q

require 'dry-initializer'

module LoveLetterApplication
  module Results
    class ProcessNextPlayerTurn
      include Dry::Initializer.define -> do
        option :process_round_complete_by_depleted_deck, type: ::Types::Callable
        option :get_next_player_node, type: ::Types::Callable
        option :get_drawn_card_node, type: ::Types::Callable
        option :next_player_draw_card, type: ::Types::Callable
        option :get_result_game_board_node, type: ::Types::Callable
        option :process_next_turn_options, type: ::Types::Callable
      end

      def call(game_board:, change_orders:)
        if game_board.draw_pile.empty?
          return process_round_complete_by_depleted_deck.(
            game_board: game_board,
            change_orders: change_orders)
        end
        next_player_id = get_next_player_id_from(game_board)
        card_id = game_board.draw_pile.first.id.to_i
        game_board = next_player_draw_card.(
          game_board: game_board,
          next_player_id: next_player_id)
        process_next_turn_options.(
          game_board: game_board,
          change_orders: change_orders
            .push(get_next_player_node.(player_id: next_player_id))
            .push(get_drawn_card_node.(player_id: next_player_id, card_id: card_id))
            .push(get_result_game_board_node.(game_board: game_board)))
      end

      private
      def get_next_player_id_from(game_board)
        current_player_id = game_board.current_player_id.to_i
        current_player = game_board.players.find{|player| player.id.to_i.eql?(current_player_id)}
        possible_players = game_board
          .players
          .select(&:active?)
          .sort{|p, q| p.seat.to_i <=> q.seat.to_i}
          .reject{|player| player.id.to_i.eql?(current_player_id)}
        #get first active player with higher seat number than current player
        next_player = possible_players
          .select{|player| player.seat.to_i > current_player_id.to_i}
          .first
        #if no such player, "wrap around" and get active player with lowest seat number
        next_player || possible_players.first

        next_player.id.to_i
      end
    end
  end
end

