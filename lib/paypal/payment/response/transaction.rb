module Paypal
  module Payment
    class Response::Transaction < Base
      cattr_reader :attribute_mapping
      @@attribute_mapping = {
        :TRANSACTIONID => :transaction_id,
        :EMAIL => :email,
        :STATUS => :status
      }
      attr_accessor *@@attribute_mapping.values

      def initialize(attributes = {})
        attrs = attributes.dup
        @@attribute_mapping.each do |key, value|
          self.send "#{value}=", attrs.delete(key)
        end

        # warn ignored params
        attrs.each do |key, value|
          Paypal.log "Ignored Parameter (#{self.class}): #{key}=#{value}", :warn
        end
      end
    end
  end
end
