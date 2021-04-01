# frozen_string_literal: true

require 'dry-struct'
require 'love_letter_application/types/game_board'
require 'love_letter_application/types/card'
require 'love_letter_application/types/player'

module LoveLetterApplication
  module Models
    class GameBoard < Dry::Struct
      attribute :players, ::Types::Array::of(LoveLetterApplication::Types::Player)
      attribute :draw_pile, ::Types::Array::of(LoveLetterApplication::Types::Card)
      attribute :set_aside_card, LoveLetterApplication::Types::Card
      attribute :current_player_id, ::Types::Coercible::Integer
      attribute :game_state, LoveLetterApplication::Types::GameStateEnum
      def to_h
        {
          players: players.map(&:to_h),
          draw_pile: draw_pile.map(&:to_h),
          set_aside_card: set_aside_card.to_h,
          current_player_id: current_player_id,
          game_state: game_state
        }
      end
    end
  end
end

