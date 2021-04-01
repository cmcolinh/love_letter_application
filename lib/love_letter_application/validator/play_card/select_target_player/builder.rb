#frozen string_literal: true

require 'dry-initializer'
require 'dry-validation'
require 'love_letter_application/validator/play_card/select_target_player'

module LoveLetterApplication
  module Validator
    class PlayCard
      class SelectTargetPlayer < Dry::Validation::Contract
        class Builder
          extend Dry::Initializer
          option :target_self?, as: :target_self, type: ::Types::Strict::Bool
          option :no_options_validator, type: ::Types::Callable

          def call(model)
            legal_target_player_ids = get_legal_target_player_ids(model)
            if legal_target_player_ids.empty?
              no_options_validator
            else
              LoveLetterApplication::Validator::PlayCard::SelectTargetPlayer::new(
                legal_target_player_ids: legal_target_player_ids)
            end
          end

          private
          def get_legal_target_player_ids(model)
            legal_target_players = model.players
              .select(&:active?) # must not be an eliminated player
              .select(&:targetable?) # can't have immunity to targeting (e.g. with priestess)
            if !target_self?
              legal_target_players = legal_target_players
                .reject{|p| p.id.to_i.eql?(model.current_player_id.to_i)} # can't target self
            end
            legal_target_players.map{|p| p.id.to_i}
          end

          def target_self?;@target_self;end
        end
      end
    end
  end
end

