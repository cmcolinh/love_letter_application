#frozen string_literal: true

require 'dry-validation'
require 'dry-initializer'
require 'love_letter_application/validator/play_card/soldier'

module LoveLetterApplication
  module Validator
    class PlayCard
      class Soldier < Dry::Validation::Contract
        class Builder
          include Dry::Initializer.define -> do
            option :no_options_validator, type: ::Types::Callable
          end

          def call(model)
            card_id = LoveLetterApplication::Actions::Soldier::id,
            legal_target_player_ids = get_legal_target_player_ids(model)
            if legal_target_player_ids.empty?
              no_options_validator
            else
              LoveLetterApplication::Validator::PlayCard::Soldier::new(
                legal_target_player_ids: legal_target_player_ids,
                legal_target_card_ids: get_legal_target_card_ids(model))
            end
          end

          private
          def get_legal_target_player_ids(model)
            model.players
              .select(&:active?) # must not be an eliminated player
              .select(&:targetable?) # can't have immunity to targeting (e.g. with priestess)
              .reject{|p| p.id.to_i.eql?(model.current_player_id.to_i)} # can't target self
              .map{|p| p.id.to_i}
          end

          def get_legal_target_card_ids(model)
            legal_target_cards = [model.set_aside_card] + model.draw_pile
            model.players.each{|p| legal_target_cards += p.played_cards + p.hand}
            legal_target_cards.select(&:targetable?)
              .map{|c| c.id.to_i}
              .uniq
          end
        end
      end
    end
  end
end

