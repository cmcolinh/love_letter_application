# frozen_string_literal: true

require 'dry-initializer'

module LoveLetterApplication
  module Results
    class ProcessRoundCompleteByDepletedDeck
      extend Dry::Initializer
      option :log_deck_depleted_node, type: ::Types.Interface(:accept), reader: :private
      option :get_players_and_scores_node, type: ::Types::Callable, reader: :private
      option :get_player_victory_node, type: ::Types::Callable, reader: :private
      option :round_complete, type: ::Types::Callable, reader: :private
      option :get_result_game_board_node, type: ::Types::Callable, reader: :private

      def call(game_board:, change_orders:)
        players_and_scores = get_players_and_scores(game_board)
        victorious_player_id = get_victorious_player_id(game_board, players_and_scores)
        game_board = round_complete.call(
          game_board: game_board,
          victorious_player_id: victorious_player_id)
        change_orders
          .push(get_players_and_scores_node.(players_and_scores: players_and_scores))
          .push(get_player_victory_node.(player_id: victorious_player_id))
          .push(get_result_game_board.(game_board: game_board))
      end

      private
      def get_players_and_scores(game_board)
        game_board.players
          .select(&:active?)
          .map{|player| [player.id, point_value_of(player)]}
          .to_h
      end

      def point_value_of(player)
        hand_card_value = hand_card.reduce{|c,d| c.rank.to_i + d.rank.to_i} * 100
        played_cards_value = player.played_cards.reduce{|c, d| c.rank.to_i + d.rank.to_i}
        hand_card_value + played_cards_value
      end

      def get_victorious_player_id(game_board, players_and_scores)
        winning_score = players_and_scores.to_a.map(&:last).max
        players_and_scores.map{|k, v| v.eql?(winning_score)}
          .map(&:id)
          .map(&:to_i)
      end
    end
  end
end

