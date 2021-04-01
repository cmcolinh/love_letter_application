# frozen_string_literal: true

require 'love_letter_application/models/game_board'
require 'love_letter_application/models/player'

module LoveLetterApplication
  module Models
    class Effects
      class SwitchHands
        def call(game_board:, player_id:, target_player_id:)
          player_replacement = get_replacement(game_board.players, player_id, target_player_id)
          target_replacement = get_replacement(game_board.players, target_player_id, player_id)

          players = game_board
            .players
            .reject{|player| [player_id.to_i, target_player_id.to_i].include?(player.id.to_i)}
            .push(player_replacement)
            .push(target_replacement)
            .freeze

          LoveLetterApplication::Models::GameBoard::new(
            players: players,
            draw_pile: game_board.draw_pile.map(&:itself).freeze,
            set_aside_card: game_board.set_aside_card,
            current_player_id: game_board.current_player_id.to_i,
            game_state: game_board.game_state)
        end

        private
        def get_replacement(players, player_id, target_player_id)
          player_to_replace = players
            .find{|player| player.id.to_i.eql?(player_id.to_i)}
          hand_to_replace_with = players
            .find{|player| player.id.to_i.eql?(target_player_id.to_i)}
            .hand
            .map(&:itself)
            .freeze
          LoveLetterApplication::Models::Player::new(
            id: player_to_replace.id.to_i,
            seat: player_to_replace.id.to_i,
            played_cards: player_to_replace.played_cards.map(&:itself).freeze,
            hand: hand_to_replace_with,
            active?: player_to_replace.active?,
            targetable?: player_to_replace.targetable?)
        end
      end
    end
  end
end

