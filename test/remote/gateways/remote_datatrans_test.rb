require 'test_helper'

class RemoteDatatransTest < Test::Unit::TestCase
  

  def setup
    @gateway = DatatransGateway.new(
                 :login => 'login',
                 :password => 'password'
               )
    
    @amount = 100
    @visa_credit_card = credit_card('4000100011112224')
    @declined_card = credit_card('4000300011112220')
    
    @options = { 
      :order_id => '1',
      :billing_address => address,
      :description => 'Store Purchase',
      :merchant_id => '1000011907',
      :refno => '23232301'
    }
  end
  
  def test_capture
#    assert response = 
      @gateway.capture(1000, 608579429, @options)
#    assert_success response
#    assert_equal 'OK', response.message
  end
#  def test_successful_purchase
#    assert response = @gateway.purchase(@amount, @visa_credit_card, @options)
#    assert_success response
#    assert_equal 'REPLACE WITH SUCCESS MESSAGE', response.message
#  end
#
#  def test_unsuccessful_purchase
#    assert response = @gateway.purchase(@amount, @declined_card, @options)
#    assert_failure response
#    assert_equal 'REPLACE WITH FAILED PURCHASE MESSAGE', response.message
#  end
#
#  def test_authorize_and_capture
#    amount = @amount
#    assert auth = @gateway.authorize(amount, @visa_credit_card, @options)
#    assert_success auth
#    assert_equal 'Success', auth.message
#    assert auth.authorization
#    assert capture = @gateway.capture(amount, auth.authorization)
#    assert_success capture
#  end
#
#  def test_failed_capture
#    assert response = @gateway.capture(@amount, '')
#    assert_failure response
#    assert_equal 'REPLACE WITH GATEWAY FAILURE MESSAGE', response.message
#  end
#
#  def test_invalid_login
#    gateway = DatatranGateway.new(
#                :login => '',
#                :password => ''
#              )
#    assert response = gateway.purchase(@amount, @visa_credit_card, @options)
#    assert_failure response
#    assert_equal 'REPLACE WITH FAILURE MESSAGE', response.message
#  end
end
