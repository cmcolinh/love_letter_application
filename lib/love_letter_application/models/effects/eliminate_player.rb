# frozen_string_literal: true

require 'love_letter_application/models/game_board'
require 'love_letter_application/models/player'

module LoveLetterApplication
  module Models
    class Effects
      class EliminatePlayer
        def call(game_board:, player_id:)
          eliminated_player_replacement = get_replacement(game_board.players, player_id)

          players = game_board
            .players
            .reject{|player| player.id.to_i.eql?(player_id.to_i)}
            .push(eliminated_player_replacement)
            .freeze

          LoveLetterApplication::Models::GameBoard::new(
            players: players,
            draw_pile: game_board.draw_pile.map(&:itself).freeze,
            set_aside_card: game_board.set_aside_card,
            current_player_id: game_board.current_player_id.to_i,
            game_state: game_board.game_state)
        end

        private
        def get_replacement(players, player_id)
          eliminated_player = players
            .find{|player| player.id.to_i.eql?(player_id.to_i)}
          LoveLetterApplication::Models::Player::new(
            id: eliminated_player.id.to_i,
            seat: eliminated_player.id.to_i,
            played_cards: (eliminated_player.played_cards + eliminated_player.hand).freeze,
            hand: [].freeze,
            active?: false,
            targetable?: false)
        end
      end
    end
  end
end

