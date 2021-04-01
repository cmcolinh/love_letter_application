# frozen_string_literal: true

require 'dry-initializer'

module LoveLetterApplication
  module Results
    class ProcessKnightShowdown
      @@execute = [
        ->(pks, cid, tid, gb, co){pks.send(:do_victory, tid, cid, gb, co)},
        ->(pks, cid, tid, gb, co){pks.send(:do_draw, cid, tid, gb, co)},
        ->(pks, cid, tid, gb, co){pks.send(:do_victory, cid, tid, gb, co)}]

      include Dry::Initializer.define -> do
        option :knight_drawn_node, type: ::Types.Interface(:accept)
        option :get_knight_victory_node, type: ::Types::Callable
        option :eliminate_player, type: ::Types::Callable
        option :process_next_player_turn, type: ::Types::Callable
      end

      def call(target_player_id:, game_board:, change_orders:)
        current_player_id = game_board.current_player_id.to_i
        result = get_result(current_player_id, target_player_id, game_board)
        @@execute[result].(self, current_player_id, target_player_id, game_board, change_orders)
      end

      private
      def get_result(current_player_id, target_player_id, game_board)
        current_player = game_board.players.find{|player| player.id.to_i.eql?(current_player_id)}
        target_player = game_board.players.find{|player| player.id.to_i.eql?(target_player_id)}
        #<=> returns -1, 0, or 1.  I add 1 at the end so I can use the result as an array index
        (current_player.hand.first.rank.to_i <=> target_player.hand.first.rank.to_i) + 1
      end

      def do_draw(current_player_id, target_player_id, game_board, change_orders)
        process_next_player_turn.(
          game_board: game_board,
          change_orders: change_orders.push(knight_drawn_node))
      end

      def do_victory(winning_player_id, losing_player_id, game_board, change_orders)
        eliminate_player.(
          target_player_id: losing_player_id,
          game_board: game_board,
          change_orders: change_orders.push(get_knight_victory_node.(
            winning_player_id: winning_player_id,
            losing_player_id: losing_player_id)))
      end
    end
  end
end
