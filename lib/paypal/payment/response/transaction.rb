module Paypal
  module Payment
    class Response::Transaction < Base
      attr_optional :transaction_id, :timestamp, :email, :status
    end
  end
end
