# frozen_string_literal: true

require 'dry-initializer'

module LoveLetterApplication
  module Validator
    class GetLegalCardIds
      include Dry::Initializer.define -> do
        option :validate_card_combo_for, type: ::Types::ArrayOfCallable
      end

      def call(card_list:)
        legal_card_ids = ::Types::ArrayOfStrictInteger.call(card_list.map{|c| c.id.to_i})
        card_list.uniq.each do |card|
          legal_card_ids = legal_card_ids
            .&(validate_card_combo_for[card.id.to_i].call(card_list: card_list))
        end
        legal_card_ids.sort
      end
    end
  end
end

