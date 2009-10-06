require 'xml'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class DatatransGateway < Gateway
      TEST_URL = 'http://pilot.datatrans.biz/upp/jsp/XML_processor.jsp'
      LIVE_URL = 'http://payment.datatrans.biz/upp/jsp/XML_processor.jsp'

      # Datatrans status success code
      DATATRANS_STATUS_SUCCESS = 'trxStatus = response'
      # Datatrans status error code
      DATATRANS_STATUS_ERROR = 'trxStatus = error'
      
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
      
      def initialize(options = {})
        requires!(options, :login, :password)
        @options = options
        super
      end
      
      def authorize(money, creditcard, options = {})
#        post = {}
#        add_invoice(post, options)
#        add_creditcard(post, creditcard)
#        add_address(post, creditcard, options)
#        add_customer_data(post, options)
#
#        commit('authonly', money, post)
      end
      
      def purchase(money, creditcard, options = {})
#        post = {}
#        add_invoice(post, options)
#        add_creditcard(post, creditcard)
#        add_address(post, creditcard, options)
#        add_customer_data(post, options)
#
#        commit('sale', money, post)
      end                       
    
      def capture(money, authorization, options = {})
        doc = ""
        xml = Builder::XmlMarkup.new(:target => doc, :indent => 2)
        xml.instruct!
        xml.paymentService(:version => '1'){
          xml.body(:merchantId => options[:merchant_id], :testOnly => test? ? 'yes' : 'no' ){
            xml.transaction(:refno => options[:refno]){
              xml.request{
                xml.amount(
                  money
                )
                xml.currency(
                  self.default_currency || options[:currency]
                )
                xml.authorizationCode(
                  authorization
                )
              }
            }
          }
        }
        url = URI.parse(test? ? TEST_URL : LIVE_URL)
        headers = {"Content-Type" => "text/xml"}
        h = Net::HTTP.new(url.host, url.port)
        h.use_ssl = false
        resp = h.post(url.path, doc, headers)
        response = parse(resp.body)
        commit(response)
      end

      private

      def parse(data)
        response = {}
        source = XML::Document.string(data)
        response[:status] = source.find('//@trxStatus').to_a
        response
      end
      
      def commit(response)
#        puts response[:status]
#        puts DATATRANS_STATUS_SUCCESS
#        puts DATATRANS_STATUS_ERROR.eql?(response[:status].to_s)
        Response.new(response[:status].to_s.eql?(DATATRANS_STATUS_SUCCESS), response[:reason], response,
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

