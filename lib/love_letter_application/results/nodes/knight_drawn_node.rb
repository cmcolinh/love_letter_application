# frozen_string_literal: true

module LoveLetterApplication
  module Results
    module Nodes
      class KnightDrawnNode
        def accept(visitor, **args)
          visitor = ::Types.Interface(:handle_knight_drawn).call(visitor)
          visitor.handle_knight_drawn(self, args)
        end
      end
    end
  end
end

