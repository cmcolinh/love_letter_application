# frozen_string_literal: true

require 'dry-initializer'
require 'love_letter_application/models/game_board'
require 'love_letter_application/models/player'

module LoveLetterApplication
  module Models
    class Effects
      class MakePlayerNotTargetable
        def call(game_board:, player_id:)
          player_replacement = get_replacement(game_board.players, player_id)

          players = game_board
            .players
            .reject{|player| player.id.to_i.eql?(player_id.to_i)}
            .push(player_replacement)

          LoveLetterApplication::Models::GameBoard::new(
            players: players,
            draw_pile: game_board.draw_pile,
            set_aside_card: game_board.set_aside_card,
            current_player_id: game_board.current_player_id,
            game_state: game_board.game_state)
        end

        private
        def get_replacement(players, player_id)
          modified_player = players
            .find{|player| player.id.to_i.eql?(player_id.to_i)}

          LoveLetterApplication::Models::Player::new(
            id: modified_player.id.to_i,
            seat: modified_player.id.to_i,
            played_cards: modified_player.played_cards,
            hand: modified_player.hand,
            active?: modified_player.active?,
            targetable?: false)
        end
      end
    end
  end
end

