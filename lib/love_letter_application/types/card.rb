#frozen string_literal: true

module LoveLetterApplication
  module Types
    i = Class::new do
      @@has_card_methods = ::Types.Interface(:id, :rank, :targetable?)

      def call(card)
        @@has_card_methods.call(card)
        ::Types::Coercible::Integer.call(card.id)
        ::Types::Coercible::Integer.call(card.rank)
        ::Types::Strict::Bool.call(card.targetable?)
        card
      end
    end.new

    LoveLetterApplication::Types::Card = ::Types::Constructor(Class){|value| i.call(value)}
  end
end

