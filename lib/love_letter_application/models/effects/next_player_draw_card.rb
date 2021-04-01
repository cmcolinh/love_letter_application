# frozen_string_literal: true

require 'dry-initializer'
require 'love_letter_application/models/game_board'
require 'love_letter_application/types/player'
require 'love_letter_application/types/game_board'

module LoveLetterApplication
  module Models
    class Effects
      class NextPlayerDrawCard
        def call(game_board:, next_player_id:)
          draw_pile = game_board.draw_pile
          player_replacement = get_replacement(game_board.players, next_player_id, draw_pile)
          players = game_board
            .players
            .reject{|player| player.id.to_i.eql?(next_player_id.to_i)}
            .push(player_replacement)
            .freeze

          draw_pile = game_board.draw_pile[1..-1].map(&:itself).freeze

          LoveLetterApplication::Models::GameBoard::new(
            players: players,
            draw_pile: draw_pile,
            set_aside_card: game_board.set_aside_card,
            current_player_id: next_player_id,
            game_state: LoveLetterApplication::Types::GameStateEnum.call('card_drawn'))
        end

        private
        def get_replacement(players, player_id, draw_pile)
          next_player = players.find{|player| player.id.eql?(player_id.to_i)}
          LoveLetterApplication::Models::Player::new(
            id: next_player.id.to_i,
            seat: next_player.seat.to_i,
            played_cards: next_player.played_cards.map(&:itself).freeze,
            hand: next_player.hand.map(&:itself).push(draw_pile.first).freeze,
            active?: next_player.active?,
            targetable?: true) # limitations on being targeted expire when player's turn again
        end
      end
    end
  end
end
