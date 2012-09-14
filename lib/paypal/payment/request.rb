module Paypal
  module Payment
    class Request < Base
      attr_optional :action, :currency_code, :description, :notify_url, :billing_type,
        :billing_agreement_description, :billing_agreement_id, :seller_paypal_account_id,
        :payment_request_id, :address, :invoice_number, :note
      attr_accessor :amount, :items

      def initialize(attributes = {})
        @amount = if attributes[:amount].is_a?(Common::Amount)
          attributes[:amount]
        else
          Common::Amount.new(
            :total => attributes[:amount],
            :tax => attributes[:tax_amount],
            :shipping => attributes[:shipping_amount],
            :item => attributes[:subtotal]
          )
        end
        @items = []
        Array(attributes[:items]).each do |item_attrs|
          @items << Item.new(item_attrs)
        end
        super
      end

      def to_params(index = 0)
        params = {
          :"PAYMENTREQUEST_#{index}_PAYMENTACTION" => self.action,
          :"PAYMENTREQUEST_#{index}_AMT" => Util.formatted_amount(self.amount.total),
          :"PAYMENTREQUEST_#{index}_TAXAMT" => Util.formatted_amount(self.amount.tax),
          :"PAYMENTREQUEST_#{index}_SHIPPINGAMT" => Util.formatted_amount(self.amount.shipping),
          :"PAYMENTREQUEST_#{index}_CURRENCYCODE" => self.currency_code,
          :"PAYMENTREQUEST_#{index}_DESC" => self.description,
          :"PAYMENTREQUEST_#{index}_NOTETEXT" => self.note,

          #Address Fields
          "PAYMENTREQUEST_#{index}_SHIPTONAME"        => self.address[:name],
          "PAYMENTREQUEST_#{index}_SHIPTOSTREET"      => self.address[:street],
          "PAYMENTREQUEST_#{index}_SHIPTOSTREET2"     => self.address[:street2],
          "PAYMENTREQUEST_#{index}_SHIPTOCITY"        => self.address[:city],
          "PAYMENTREQUEST_#{index}_SHIPTOSTATE"       => self.address[:state],
          "PAYMENTREQUEST_#{index}_SHIPTOCOUNTRYCODE" => self.address[:countrycode],
          "PAYMENTREQUEST_#{index}_SHIPTOPHONENUM"    => self.address[:phonenum],
          "PAYMENTREQUEST_#{index}_SHIPTOZIP"         => self.address[:zip],

          "PAYMENTREQUEST_#{index}_INVNUM"        => self.invoice_number,
          "PAYMENTREQUEST_#{index}_NOTETEXT"      => self.note,

          # 3rd-party Recipient
          "PAYMENTREQUEST_#{index}_SELLERPAYPALACCOUNTID" => self.seller_paypal_account_id,

          "PAYMENTREQUEST_#{index}_PAYMENTREQUESTID" => self.payment_request_id,

          # NOTE:
          #  notify_url works only when DoExpressCheckoutPayment called.
          #  recurring payment doesn't support dynamic notify_url.
          :"PAYMENTREQUEST_#{index}_NOTIFYURL" => self.notify_url,
          :"L_BILLINGTYPE#{index}" => self.billing_type,
          :"L_BILLINGAGREEMENTDESCRIPTION#{index}" => self.billing_agreement_description
        }.delete_if do |k, v|
          v.blank?
        end
        if self.items.present?
          params[:"PAYMENTREQUEST_#{index}_ITEMAMT"] = Util.formatted_amount(self.items_amount)
          self.items.each_with_index do |item, item_index|
            params.merge! item.to_params(index, item_index)
          end
        end
        params
      end

      def items_amount
        self.items.inject(0.0) do |total, item|
          total += item.quantity * item.amount.to_f
        end
      end
    end
  end
end
