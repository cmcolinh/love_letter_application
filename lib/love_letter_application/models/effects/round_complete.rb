# frozen_string_literal: true

require 'love_letter_application/models/game_board'
require 'love_letter_application/types/game_board'

module LoveLetterApplication
  module Models
    class Effects
      class RoundComplete
        def call(game_board:, victorious_player_id:)
          victorious_player_id = ::Types::Array::of(::Types::Strict::Integer)
            .call(victorious_player_id)
          next_player_id = game_board.players
            .select{|player| victorious_player_id.include?(player.id.to_i)}
            .max{|p, q| p.id.to_i <=> q.id.to_i}
            .id

          LoveLetterApplication::Models::GameBoard::new(
            players: game_board.players,
            draw_pile: game_board.draw_pile,
            set_aside_card: game_board.set_aside_card,
            current_player_id: next_player_id,
            game_state: LoveLetterApplication::Types::GameStateEnum.call('round_complete'))
        end
      end
    end
  end
end

