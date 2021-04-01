# frozen_string_literal: true

require 'dry-initializer'
require 'love_letter_application/types/card'

module LoveLetterApplication
  module Models
    class Player
      include Dry::Initializer.define -> do
        option :id, type: ::Types::Coercible::Integer
        option :seat, type: ::Types::Coercible::Integer
        option :played_cards, type: ::Types::Array::of(LoveLetterApplication::Types::Card)
        option :hand, type: ::Types::Array::of(LoveLetterApplication::Types::Card)
        option :active?, as: :active, type: ::Types::Strict::Bool, reader: false
        option :targetable?, as: :targetable, type: ::Types::Strict::Bool, reader: false
      end
      def active?;@active;end
      def targetable?;@targetable;end
      def inspect
        "#<#{self.class} id=#{id}, seat=#{seat} played_cards=#{played_cards} hand=#{hand} " +
          "targetable?=#{targetable?} active?=#{active?}>"
      end
      def to_h
        { 
          id: id,
          seat: seat,
          played_cards: played_cards.map(&:to_h),
          hand: hand.map(&:to_h),
          targetable?: targetable?,
          active?: active?
        }
      end
    end
  end
end

