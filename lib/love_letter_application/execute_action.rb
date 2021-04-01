# frozen_string_literal: true

require 'love_letter_application/love_letter_imports'

module LoveLetterApplication
  class ExecuteAction
    include LoveLetterApplication::LoveLetterImports[
      new_change_orders: 'love_letter_application.change_orders_initializer',
      game_board_type: 'love_letter_application.types.game_board',
      build_validator: 'love_letter_application.build_validator']

    def call(action_hash:, game_board:, user:, last_action_id:)
      game_board_type.call(game_board)
      validate = build_validator.(game_board: game_board, last_action_id: last_action_id)
      execute_action = validate.(action_hash: action_hash, user: user)
      change_orders = new_change_orders.()
      execute_action.(game_board: game_board, change_orders: change_orders)
    end
  end
end

