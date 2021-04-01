# frozen_string_literal: true

require 'dry-initializer'

module LoveLetterApplication
  module Results
    module Nodes
      class LogNode
        extend Dry::Initializer
        option :message, type: ::Types::Coercible::String

        def accept(visitor, **args)
          visitor = Types.Interface(:handle_log_message).call(visitor)
          visitor.handle_log_message(self, args)
        end
      end
    end
  end
end

