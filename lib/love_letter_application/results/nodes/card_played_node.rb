# frozen_string_literal: true

require 'dry-struct'

module LoveLetterApplication
  module Results
    module Nodes
      class CardPlayedNode < Dry::Struct
        attribute :player_id, ::Types::Strict::Integer
        attribute :card_id, ::Types::Strict::Integer
      end
    end
  end
end

