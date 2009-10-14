require 'test_helper'

class RemoteDatatransTest < Test::Unit::TestCase

  # Insert here your access data from DataTrans for the RemoteTest
  # You need to create two orders, so that one can be captured and the other void
  def setup
    @gateway = DatatransGateway.new(
                 :login => '', # Insert here your Datatrans login
                 :password => '', # and here your Datatrans password
                 :merchant_id => '' # here insert your Datatrans Merchant ID
               )
    
    @amount = 1000
    
    @options = {
      :refno => '', # insert here the Reference Number of the order
      :amount => 1000
    }
    @options_capture = {
      :refno => '' # insert here the Reference Number of the order
    }
  end
  
  def test_capture
    assert response = @gateway.capture(@amount, 933486941, @options_capture) # the authorization code has to updated before this testing
    assert_equal true, response.success?, 'If failed check if refno is in the datatrans system and unsettled'
  end

  def test_capture_failed
    assert response = @gateway.capture(@amount, 608579429, @options_capture)
    assert_false(response.success?, 'Capture failed')
  end

  def test_void
    assert response = @gateway.void(2826987, @options)
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
