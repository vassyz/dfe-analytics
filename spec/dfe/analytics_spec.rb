# frozen_string_literal: true

RSpec.describe DfE::Analytics do
  it 'has a version number' do
    expect(DfE::Analytics::VERSION).not_to be nil
  end

  it 'has documentation entries for all the config options' do
    config_options = DfE::Analytics.config.members

    config_options.each do |option|
      expect(I18n.t("dfe.analytics.config.#{option}.description")).not_to match(/translation missing/)
      expect(I18n.t("dfe.analytics.config.#{option}.default")).not_to match(/translation missing/)
    end
  end

  describe 'initalization' do
    # field validity is computed from allowlist, blocklist and database. See
    # Analytics::Fields for more details
    context 'when the field lists are valid' do
      it 'raises no error' do
        expect { DfE::Analytics.initialize! }.not_to raise_error
      end
    end

    context 'when a field list is invalid' do
      before do
        allow(DfE::Analytics).to receive(:allowlist).and_return({ invalid: [:fields] })
      end

      it 'raises an error' do
        expect { DfE::Analytics.initialize! }.to raise_error(DfE::Analytics::ConfigurationError)
      end
    end
  end

  it 'raises a configuration error on missing config values' do
    with_analytics_config(bigquery_project_id: nil) do
      DfE::Analytics::Testing.webmock! do
        expect { DfE::Analytics.events_client }.to raise_error(DfE::Analytics::ConfigurationError)
      end
    end
  end

  describe '#entities_for_analytics' do
    before do
      allow(DfE::Analytics).to receive(:allowlist).and_return({
        candidates: %i[id],
        institutions: %i[id] # table name for the School model, which doesn’t follow convention
      })
    end

    it 'returns the entities in the allowlist' do
      expect(DfE::Analytics.entities_for_analytics).to eq %i[candidates institutions]
    end
  end
end
