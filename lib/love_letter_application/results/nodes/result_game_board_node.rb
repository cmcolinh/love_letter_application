# frozen_string_literal: true

require 'dry-struct'

module LoveLetterApplication
  module Results
    module Nodes
      class ResultGameBoardNode < Dry::Struct
        attribute :game_board, LoveLetterApplication::Types::GameBoard

        def accept(visitor, **args)
          visitor = ::Types.Interface(:handle_result_game_board).call(visitor)
          visitor.handle_result_game_board(self, args)
        end
      end
    end
  end
end

