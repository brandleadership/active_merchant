require 'test_helper'

class RemoteDatatransTest < Test::Unit::TestCase
  
  def setup
    @gateway = DatatransGateway.new(
                 :login => '11907',
                 :password => '11907',
                 :merchant_id => '1000011907'
               )
    
    @amount = 1000
    
    @options = {
      :refno => '123987',
      :amount => 1000
    }
  end
  
  def test_capture
    assert response = @gateway.capture(@amount, 422636182, @options) # the authorization code has to updated before this testing
    assert_equal true, response.success?, 'If failed check if refno is in the datatrans system and unsettled'
  end

  def test_capture_failed
    assert response = @gateway.capture(@amount, 608579429, @options)
    assert_false(response.success?, 'Capture failed')
  end

  def test_void
    assert response = @gateway.void(645212931, @options)
    assert_equal true, response.success?, 'Check if the transaction existst.'
    assert_equal 'cancellation succeeded', response.message.to_s
  end

  def test_void_failed
    assert response = @gateway.void(413866788, @options)
    assert_false response.success?, 'Check if the transaction existst.'
    assert_equal 'UPP record not found', response.message.to_s
  end

  def test_invalid_login
    gateway = DatatransGateway.new(
                :login => '',
                :password => '',
                :merchant_id => ''
              )
    assert response = gateway.capture(@amount, 608579429, @options)
    assert_failure response
    assert_equal 'invalid value', response.message.to_s
  end
  
end
