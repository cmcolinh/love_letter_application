#frozen string_literal: true 
 
require 'dry-initializer'
require 'dry-types'
require 'love_letter_application/types/card'
require 'love_letter_application/types/player'

module LoveLetterApplication
  module Types
    i = Class::new do
      @@has_game_board_methods =
        ::Types.Interface(:players, :draw_pile, :set_aside_card, :current_player_id, :game_state)
      def call(game_board)
        @@has_game_board_methods.(game_board)
        ::Types::Array::of(LoveLetterApplication::Types::Player).call(game_board.players)
        ::Types::Array::of(LoveLetterApplication::Types::Card).call(game_board.draw_pile)
        LoveLetterApplication::Types::Card.call(game_board.set_aside_card)
        ::Types::Coercible::Integer.call(game_board.current_player_id)
        LoveLetterApplication::Types::GameStateEnum.call(game_board.game_state)
        all_players_have_different_ids_and_seats(game_board.players)
        verify_current_player_id_is_valid(game_board)
        game_board
      end

      private
      def all_players_have_different_ids_and_seats(players)
        id_list = []
        seat_list = []
        players.each do |player|
          if id_list.include?(player.id.to_i)
            raise Dry::Types::ConstraintError::new(
              'All players have distinct ids', players.map(&:id))
          end
          if seat_list.include?(player.seat.to_i)
            raise Dry::Types::ConstraintError::new(
              'All players have distinct seats', players.map(&:seat))
          end
          id_list.push player.id.to_i
          seat_list.push player.seat.to_i
        end
      end

      def verify_current_player_id_is_valid(game_board)
        id_list = game_board.players.map{|player| player.id.to_i}
        if !id_list.include?(game_board.current_player_id.to_i)
          raise Dry::Types::ConstraintError::new(
            "The player id whose turn it is not in the player list (#{id_list})",
            game_board.current_player_id)
        end
      end
    end.new

    LoveLetterApplication::Types::GameBoard = ::Types::Constructor(Class){|value| i.call(value)}

    LoveLetterApplication::Types::GameStateEnum =
      ::Types::String::enum('card_drawn', 'round_complete')
  end
end

