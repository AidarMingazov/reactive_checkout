# frozen_string_literal: true

class Reactivepay::Client
  include HTTParty

  def create_payment(attributes, card, customer)
    body = prepare_json_api_body(attributes, card, customer).to_json

    HTTParty.post(base_url + 'payments', body: body, headers: headers)
  end

  private

  def headers
    {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{ENV.fetch('REACTIVEPAY_TOKEN')}"
    }
  end


  def prepare_json_api_body(attributes, card, customer)
    attributes.merge!(card: card).merge!(customer: customer)
  end

  def base_url
    @base_url ||= ENV.fetch("REACTIVEPAY_BASE_URL")
  end
end
