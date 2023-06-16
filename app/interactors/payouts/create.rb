module Payouts
  class Create
    include Interactor::Organizer

    organize Payouts::BuildPayout, Payouts::PrepareRequest, Payouts::SendCreateRequest
  end
end
