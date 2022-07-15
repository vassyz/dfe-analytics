# frozen_string_literal: true

module DfE
  module Analytics
    module Entities
      extend ActiveSupport::Concern
      include EntityCallbacks

      included do
        Rails.logger.info('DEPRECATION WARNING - it is no longer necessary to mix in DfE::Analytics::Entities. The behaviour is now included automatically based on presence in analytics.yml')
      end
    end
  end
end
