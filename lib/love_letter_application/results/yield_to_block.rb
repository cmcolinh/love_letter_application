# frozen_string_literal: true

module LoveLetterApplication
  module Results
    class YieldToBlock
      def call(**args, &block)
        yield(**args) if block_given?
      end
    end
  end
end

