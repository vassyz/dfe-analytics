module DfE
  module Analytics
    module Emails
      extend ActiveSupport::Concern

      included do
        after_action :trigger_email_event
      end

      def trigger_email_event
        data = {
          mailer: self.class.name.underscore,
          action: action_name,
          subject: message.subject,
          to: DfE::Analytics.anonymise(message.to.join(','))
        }

        event = DfE::Analytics::Event.new
                                     .with_type('email')
                                     .with_data(data)
                                     .with_request_uuid(RequestLocals.fetch(:dfe_analytics_request_id) { nil })

        DfE::Analytics::SendEvents.do([event.as_json])
      end
    end
  end
end
