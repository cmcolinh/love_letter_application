# frozen_string_literal: true

require 'love_letter_application/models/game_board'
require 'love_letter_application/models/player'

module LoveLetterApplication
  module Models
    class Effects
      class PlayCard
        def call(game_board:, card_id:)
          player_id = game_board.current_player_id.to_i
          player_replacement = get_replacement(game_board.players, player_id, card_id)

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
        def get_replacement(players, player_id, card_id)
          modified_player = players
            .find{|player| player.id.to_i.eql?(player_id.to_i)}
          played_card = modified_player.hand.find{|card| card.id.to_i.eql?(card_id.to_i)}
          new_hand = modified_player.hand.map(&:itself)
          new_hand.slice!(new_hand.index{|card| card.id.to_i.eql?(card_id.to_i)}).freeze
          new_played_cards = ([played_card] + modified_player.played_cards.map(&:itself)).freeze

          LoveLetterApplication::Models::Player::new(
            id: modified_player.id.to_i,
            seat: modified_player.id.to_i,
            played_cards: new_played_cards,
            hand: new_hand,
            active?: modified_player.active?,
            targetable?: modified_player.targetable?)
        end
      end
    end
  end
end

