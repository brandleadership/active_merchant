# Author::    Roman Simecek (mailto:roman.simecek@screenconcept.ch)
# License::   Distributes under the same terms as Ruby
require 'rexml/document'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class DatatransGateway < Gateway
      TEST_URL = 'http://pilot.datatrans.biz/upp/jsp/XML_processor.jsp'
      LIVE_URL = 'http://payment.datatrans.biz/upp/jsp/XML_processor.jsp'

      # Datatrans status accepted code
      DATATRANS_TRXSTATUS_SUCCESS = 'response'
      
      # Datatrans status error code
      DATATRANS_STATUS_SUCCESS = 'accepted'
      
      # The countries the gateway supports merchants from as 2 digit ISO country codes
      self.supported_countries = ['CH']
      
      # The card types supported by the payment gateway
      self.supported_cardtypes = [:visa, :master, :american_express, :diners_club]

      # the default currency
      self.default_currency = 'CHF'
      
      # The homepage URL of the gateway
      self.homepage_url = 'http://www.datatrans.ch'
      
      # The name of the gateway
      self.display_name = 'DataTrans'
      
      # = Datatrans Gatway
      #
      # Initialize the Datatrans Gateway
      # The parameters you will receive from Datatrans
      #
      #
      # == Usage
      #
      # === Initialize
      #
      # ==== Parameters
      # * <tt>:login</tt> - Your login for Datatrans
      # * <tt>:password</tt> - Your password for Datatrans
      # * <tt>:merchant_id</tt> - Your merchant id for Datatrans
      # ==== Example
      #  gateway = DatatransGateway.new(
      #           :login => 'login',
      #           :password => 'password',
      #           :merchant_id => '1000011907'
      #         )
      #
      # === Capture
      #
      # ==== Parameters
      # * <tt>:amount</tt> - The amount to be captured.  Either an Integer value in cents.
      # * <tt>:authorization</tt> - The authorization code received from the authorization.
      # * <tt>:options</tt>
      #   * <tt>:refno</tt> - The Reference Number of the transaction.
      # ==== Example
      #   response = @gateway.capture(:amount,
      #                              :authorization,
      #                              :options => { :refno => '23232301' }
      #                             )
      #
      #
      def initialize(options = {})
        requires!(options, :login, :password, :merchant_id)
        @options = options
        super
      end
                               
      # Capture authorized transaction from a credit card
      #
      # ==== Parameters
      # * <tt>money</tt> - The amount to be captured.  Either an Integer value in cents.
      # * <tt>authorization</tt> - The authorization code received from the authorization.
      # * <tt>options</tt>
      #   * <tt>:refno</tt> - The Reference Number of the transaction.
      #   * <tt>:currency</tt> - Optional the Currency of the transaction, default CHF.
      # 
      def capture(money, authorization, options = {})
        doc = ""
        xml = REXML::Document.new('<?xml version="1.0" encoding="UTF-8" ?>')
        root = xml.add_element "paymentService", {"version" => "1"}
        body = root.add_element "body", {"merchantId" => @options[:merchant_id], "testOnly" => test? ? 'yes' : 'no' ""}
        transaction = body.add_element "transaction", {"refno" => options[:refno]}
        request = transaction.add_element "request"
        amount = request.add_element "amount"
        amount.text = money.to_s
        currency = request.add_element "currency"
        currency.text = self.default_currency.to_s || options[:currency].to_s
        authorization_code = request.add_element "authorizationCode"
        authorization_code.text = authorization.to_s
        url = URI.parse(test? ? TEST_URL : LIVE_URL)
        headers = {"Content-Type" => "text/xml"}
        h = Net::HTTP.new(url.host, url.port)
        h.use_ssl = false
        xml.write(doc, 0)
        resp = h.post(url.path, doc, headers)
        response = parse(resp.body)
        commit(response)
      end

      private

      def parse(data)
        puts data
        response = {}
        source = REXML::Document.new(data)
        root = source.root
        body = root.get_elements("body").first
        error_code = "" || body.get_elements("errorCode").first.get_text
        error_message = "" || body.get_elements("errorMessage").first.get_text
        error_detail = "" || body.get_elements("errorDetail").first.get_text
        ref_no = "" || body.get_elements("transaction").first.attributes["refno"]
        response = {:status => body.attributes["status"].to_s,
                    :trx_status => body.get_elements("transaction").first.attributes["trxStatus"].to_s,
                    :error_code => error_code,
                    :reason => error_message,
                    :error_detail => error_detail,
                    :ref_no => ref_no
                   }
        response
      end
      
      def commit(response)
        Response.new(response[:status].to_s.eql?(DATATRANS_STATUS_SUCCESS) && response[:trx_status].to_s.eql?(DATATRANS_TRXSTATUS_SUCCESS), response[:reason], response,
          :test => test?
        )
      end

      def payment_method(creditcard)
        if(creditcard.type == 'visa')
          return 'VIS'
        elsif(creditcard.type == 'master_card')
          return 'ECA'
        elsif(creditcard.type == 'american_express')
          return 'AMX'
        elsif(creditcard.type == 'diners_club')
          return 'DIN'
        else
          return 'ERROR'
        end
      end
      
    end
  end
end

