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
        options[:amount] = money.to_s
        create_xml(authorization, options, doc = "", false)
        response = post_xml(doc)
        commit(response)
      end

      # Cancels the transaction
      #
      # ==== Parameters
      # * <tt>authorization</tt> - The authorization code received from the authorization.
      # * <tt>options</tt>
      #   * <tt>:refno</tt> - The Reference Number of the transaction.
      #   * <tt>:amount</tt> - The amount of the transaction
      #   * <tt>:currency</tt> - Optional the Currency of the transaction, default CHF.
      def void(authorization, options = {})
        create_xml(authorization, options, doc = "", true)
        response = post_xml(doc)
        commit(response)
      end

      private

      def post_xml(doc)
        url = URI.parse(test? ? TEST_URL : LIVE_URL)
        headers = {"Content-Type" => "text/xml"}
        h = Net::HTTP.new(url.host, url.port)
        h.use_ssl = false
        resp = h.post(url.path, doc, headers)
        response = parse(resp.body)
        response
      end

      def create_xml(authorization, options, doc, void)
        xml = REXML::Document.new('<?xml version="1.0" encoding="UTF-8" ?>')
        root = xml.add_element "paymentService", {"version" => "1"}
        body = root.add_element "body", {"merchantId" => @options[:merchant_id], "testOnly" => test? ? 'yes' : 'no' ""}
        transaction = body.add_element "transaction", {"refno" => options[:refno]}
        request = transaction.add_element "request"
        amount = request.add_element "amount"
        amount.text = options[:amount].to_s
        currency = request.add_element "currency"
        currency.text = self.default_currency.to_s || options[:currency].to_s
        authorization_code = request.add_element "authorizationCode"
        authorization_code.text = authorization.to_s
        reqtype = request.add_element "reqtype" if void
        reqtype.text = "DOA" if void
        xml.write(doc, 0)
        puts doc
        doc
      end

      def parse(data)
        response = {}
        source = REXML::Document.new(data)
        root = source.root
        body = root.get_elements("body").first
        transactin_error = root.get_elements("body/transaction/error").first
        error = root.get_elements("body/error").first
        if transactin_error == nil && error == nil
          message = root.get_elements("body/transaction/response/responseMessage").first.get_text
          detail = "No details"
          code = root.get_elements("body/transaction/response/responseCode").first.get_text
          ref_no = root.get_elements("body/transaction").first.attributes["refno"]
        elsif error != nil
          message = root.get_elements("body/error/errorMessage").first.get_text
          detail = root.get_elements("body/error/errorDetail").first.get_text
          code = root.get_elements("body/error/errorCode").first.get_text
          ref_no = root.get_elements("body/transaction").first.attributes["refno"]
        else
          message = root.get_elements("body/transaction/error/errorMessage").first.get_text
          detail = root.get_elements("body/transaction/error/errorDetail").first.get_text
          code = root.get_elements("body/transaction/error/errorCode").first.get_text
          ref_no = root.get_elements("body/transaction").first.attributes["refno"]
        end
        response = {:status => body.attributes["status"].to_s,
                    :trx_status => body.get_elements("transaction").first.attributes["trxStatus"].to_s,
                    :code => code,
                    :message => message,
                    :detail => detail,
                    :ref_no => ref_no
                   }
        response
      end
      
      def commit(response)
        Response.new(response[:status].to_s.eql?(DATATRANS_STATUS_SUCCESS) && response[:trx_status].to_s.eql?(DATATRANS_TRXSTATUS_SUCCESS),
                     response[:message],
                     response,
                     :test => test?
                    )
      end
      
    end
  end
end
