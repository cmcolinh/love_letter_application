# frozen_string_literal: true

require 'dry-initializer'
require 'love_letter_application/validator/play_card'

module LoveLetterApplication
  module Validator
    class Builder
      include Dry::Initializer.define -> do
        option :all_card_validator_builders, type: ::Types::ArrayOfCallable
        option :get_legal_card_ids, type: ::Types::Callable
      end

      def call(game_board:, last_action_id:)
        current_player = game_board.players.find do |player|
          player.id.to_i.eql?(game_board.current_player_id.to_i)
        end

        validate_player_action_and_user = GameValidator::Validator::Base::new(
          legal_options: ['play_card'],
          current_player_id: game_board.current_player_id,
          last_action_id: last_action_id)

        legal_card_ids = get_legal_card_ids.(card_list: current_player.hand)

        validate_card_id = ValidateCardId::new(legal_card_ids: legal_card_ids)

        card_validators = all_card_validator_builders
          .map
          .with_index{|v, k| [k, v]}
          .to_h
          .select{|k, v| legal_card_ids.include?(k)}
          .map{|k, v| [k, v.call(game_board)]}
          .to_h

        play_card = PlayCard::new(
          validate_card_id: validate_card_id,
          full_validator_for: card_validators)

        full_validator_for = 
          {['play_card', true] => play_card, ['play_card', false] => play_card}

        validate_input = GameValidator::Validator::new(
          validate_player_action_and_user: validate_player_action_and_user,
          full_validator_for: full_validator_for)
      end
    end
  end
end

