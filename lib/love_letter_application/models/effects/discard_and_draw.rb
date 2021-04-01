# frozen_string_literal: true

require 'dry-initializer'
require 'love_letter_application/models/game_board'
require 'love_letter_application/models/player'

module LoveLetterApplication
  module Models
    class Effects
      class DiscardAndDraw
        include Dry::Initializer.define -> do
          option :null_card, type: LoveLetterApplication::Types::Card
        end

        def call(game_board:, player_id:)
          draw_pile = game_board.draw_pile
          sac = game_board.set_aside_card
          player_replacement = get_replacement(game_board.players, player_id, draw_pile, sac)
          players = game_board
            .players
            .reject{|player| player.id.to_i.eql?(player_id.to_i)}
            .push(player_replacement)
            .freeze

          draw_pile = game_board.draw_pile
          draw_pile = game_board.draw_pile[1..-1].map(&:itself).freeze unless draw_pile.empty?

          LoveLetterApplication::Models::GameBoard::new(
            players: players,
            draw_pile: draw_pile,
            set_aside_card: (game_board.draw_pile.empty? ? null_card : game_board.set_aside_card),
            current_player_id: game_board.current_player_id.to_i,
            game_state: game_board.game_state)
        end

        private
        def get_replacement(players, player_id, draw_pile, set_aside_card)
          player = players.find{|player| player.id.eql?(player_id.to_i)}
          LoveLetterApplication::Models::Player::new(
            id: player.id.to_i,
            seat: player.seat.to_i,
            played_cards: (player.played_cards + player.hand).freeze,
            hand: [draw_pile.first || set_aside_card].freeze,
            active?: player.active?,
            targetable?: player.targetable?)
        end
      end
    end
  end
end

