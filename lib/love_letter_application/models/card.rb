# frozen_string_literal: true

require 'dry-struct'

module LoveLetterApplication
  module Models
    class Card
      include Dry::Initializer.define -> do
        option :id, ::Types::Coercible::Integer
        option :rank, ::Types::Coercible::Integer
        option :targetable?, as: :targetable, type: ::Types::Strict::Bool, reader: false
      end
      def targetable?;@targetable;end
      def inspect
        "#<#{self.class} id=#{id}, rank=#{rank} targetable?=#{targetable?}>"
      end
      def to_h
        {id: id, rank: rank, targetable?: targetable?}
      end
    end
  end
end

