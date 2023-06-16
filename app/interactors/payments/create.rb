module Payments
  class Create
    include Interactor::Organizer

    organize Payments::BuildPayment, Payments::PrepareRequest, Payments::SendCreateRequest
  end
end
