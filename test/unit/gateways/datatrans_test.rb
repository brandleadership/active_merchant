require 'test_helper'

class DatatransTest < Test::Unit::TestCase
  def setup
    @gateway = DatatransGateway.new(
                 :login => 'login',
                 :password => 'password',
                 :merchant_id => '1000011907'
               )

    @visa_credit_card = CreditCard.new(
                     :month      => '12',
                     :year       => '2010',
                     :type       => 'visa',
                     :number     => '4242424242424242'
                   )
    @mastercard_credit_card = CreditCard.new(
                     :month      => '12',
                     :year       => '2010',
                     :type       => 'master_card',
                     :number     => '5200000000000007'
                   )
    @amercianexpress_credit_card = CreditCard.new(
                     :month      => '12',
                     :year       => '2010',
                     :type       => 'american_express',
                     :number     => '375811111111115'
                   )
    @dinersclub_credit_card = CreditCard.new(
                     :month      => '12',
                     :year       => '2010',
                     :type       => 'diners_club',
                     :number     => '36168002586009'
                   )

    @amount = 100
    
    @options = { 
      :order_id => generate_unique_id,
      :billing_address => address,
      :description => 'Store Purchase',
      :refno => '23232301'
    }
  end

  def test_supported_countries
    assert_equal ['CH'], DatatransGateway.supported_countries
  end

  def test_supported_card_types
    assert_equal [ :visa, :master, :american_express, :diners_club ], DatatransGateway.supported_cardtypes
  end

#  def test_payment_method_visa_card
#    assert_equal 'VIS', @gateway.payment_method(@visa_credit_card)
#  end
#
#  def test_payment_method_mastercard_card
#    assert_equal 'ECA', @gateway.payment_method(@mastercard_credit_card)
#  end
#
#  def test_payment_method_amercian_express_card
#    assert_equal 'AMX', @gateway.payment_method(@amercianexpress_credit_card)
#  end
#
#  def test_payment_method_dinersclub_card
#    assert_equal 'DIN', @gateway.payment_method(@dinersclub_credit_card)
#  end

#  def test_capture
#    @gateway.capture(1000, 724607995, @options)
#  end
  
#  def test_successful_purchase
#    @gateway.expects(:ssl_post).returns(successful_purchase_response)
#
#    assert response = @gateway.purchase(@amount, @credit_card, @options)
#    assert_instance_of
#    assert_success response
#
#    # Replace with authorization number from the successful response
#    assert_equal '', response.authorization
#    assert response.test?
#  end
#
#  def test_unsuccessful_request
#    @gateway.expects(:ssl_post).returns(failed_purchase_response)
#
#    assert response = @gateway.purchase(@amount, @credit_card, @options)
#    assert_failure response
#    assert response.test?
#  end
#
#  private
#
#  # Place raw successful response from gateway here
#  def successful_purchase_response
#  end
#
#  # Place raw failed response from gateway here
#  def failed_purcahse_response
#  end
end
