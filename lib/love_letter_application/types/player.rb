#frozen string_literal: true

require 'dry-initializer'
require 'love_letter_application/types/card'

module LoveLetterApplication
  module Types
    i = Class::new do
      @@has_player_methods = ::Types.Interface(:id, :seat, :played_cards, :hand, :active?)

      def call(player)
        @@has_player_methods.(player)
        ::Types::Coercible::Integer.call(player.id)
        ::Types::Coercible::Integer.call(player.seat)
        ::Types::Array::of(LoveLetterApplication::Types::Card).call(player.played_cards)
        ::Types::Array::of(LoveLetterApplication::Types::Card).call(player.hand)
        ::Types::Strict::Bool.call(player.active?)
        player
      end
    end.new

    LoveLetterApplication::Types::Player = ::Types::Constructor(Class){|value| i.call(value)}
  end
end

