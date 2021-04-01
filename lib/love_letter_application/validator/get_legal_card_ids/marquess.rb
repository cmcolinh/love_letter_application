# frozen_string_literal: true

module LoveLetterApplication
  module Validator
    class GetLegalCardIds
      class Marquess
        def call(card_list:)
          if card_list.map{|card| card.rank.to_i}.sum >= 12
            card_list.map{|card| card.id.to_i}.select{|card_id| card_id.eql?(7)}
          else
            card_list.map{|card| card.id.to_i}
          end
        end
      end
    end
  end
end

