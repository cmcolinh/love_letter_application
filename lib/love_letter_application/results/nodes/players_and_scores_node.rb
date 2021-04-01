# frozen_string_literal: true

require 'dry-struct'

module LoveLetterApplication
  module Results
    module Nodes
      class PlayersAndScoresNode
        class PlayerScore < Dry::Struct
          attribute :hand_card_value
          attribute :played_cards_value
        end

        def initialize(players_and_scores:)
          @players_and_scores = players_and_scores
            .sort
            .reverse
            .map{|k, v| [k, get_inner_node_for(v)]}
            .freeze
        end

        def players_and_scores
          @players_and_scores
        end

        def accept(visitor, **args)
          visitor = ::Types.Interface(:handle_players_and_scores).call(visitor)
          visitor.handle_players_and_scores(self, args)
        end

        private
        def get_inner_node_for(score)
          hand_card_value = score / 100
          played_cards_value = score % 100

          PlayerScore::new(
            hand_card_value: hand_card_value,
            played_cards_value: played_cards_value)
        end
      end
    end
  end
end

