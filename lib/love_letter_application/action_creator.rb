# frozen_string_literal: true

require 'dry-initializer'

module LoveLetterApplication
  class ActionCreator
    extend Dry::Initializer

    option :actions, type: Types::Array.of(Types.Interface(:call))

    def call(validation_result)
      actions[validation_result.card_to_play]
    end
  end
end

