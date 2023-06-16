require 'rails_helper'

describe Payments::Create do
  describe '.organized' do
    let(:expected_interactors) do
      [
        Payments::BuildPayment,
        Payments::PrepareRequest,
        Payments::SendCreateRequest
      ]
      end

    subject { described_class.organized }

    it { is_expected.to eq(expected_interactors) }
  end
end
