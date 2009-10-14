require 'test_helper'

class DatatransTest < Test::Unit::TestCase
  def setup
    @gateway = DatatransGateway.new(
                 :login => '11011',
                 :password => '11011',
                 :merchant_id => '1000011011'
               )

    @amount = 1000

    @options_void = {
      :refno => '123987',
      :amount => 1000
    }

    @options_capture = {
      :refno => '123987'
    }
  end

  def test_capture_accepted
    @gateway.expects(:post_xml).returns(post_xml_capture_accepted)
    assert response = @gateway.capture(@amount, 933486941, @options_capture)
    assert_equal true, response.success?
    assert_equal 'settlement succeeded', response.message.to_s
  end

  def test_capture_false_authorization
    @gateway.expects(:post_xml).returns(post_xml_capture_failed_false_authorization)
    assert response = @gateway.capture(@amount, 933486941, @options_capture)
    assert_equal false, response.success?
    assert_equal 'UPP record not found', response.message.to_s
  end

  def test_capture_allready_done
    @gateway.expects(:post_xml).returns(post_xml_capture_failed_already_settled)
    assert response = @gateway.capture(@amount, 933486941, @options_capture)
    assert_equal false, response.success?
    assert_equal 'cannot be settled', response.message.to_s
  end

  def test_invalid_login
    @gateway.expects(:post_xml).returns(post_xml_invalid_login)
    assert response = @gateway.capture(@amount, 933486941, @options_capture)
    assert_equal false, response.success?
    assert_equal 'invalid value', response.message.to_s
    assert_equal 'merchantId()', response.params['detail'].to_s
  end

  def test_supported_countries
    assert_equal ['CH'], DatatransGateway.supported_countries
  end

  def test_supported_card_types
    assert_equal [ :visa, :master, :american_express, :diners_club ], DatatransGateway.supported_cardtypes
  end

  def test_void
    @gateway.expects(:post_xml).returns(post_xml_void_accepted)
    assert response = @gateway.void(2826987, @options_void)
    assert_equal true, response.success?, 'Check if the transaction existst.'
    assert_equal 'cancellation succeeded', response.message.to_s
  end

  def test_void_failed
    @gateway.expects(:post_xml).returns(post_xml_void_failed_not_found)
    assert response = @gateway.void(413866788, @options_void)
    assert_false response.success?, 'Check if the transaction existst.'
    assert_equal 'invalid value', response.message.to_s
  end

  private

  def post_xml_capture_accepted
    <<-RESPONSE
<?xml version='1.0' encoding='UTF-8'?>
<paymentService version='1'>
  <body merchantId='1000011011' testOnly='yes' status='accepted'>
    <transaction refno='628a069429b4453bb2' trxStatus='response'>
      <request>
        <amount>100</amount>
        <currency>CHF</currency>
        <authorizationCode>632351067</authorizationCode>
        <reqtype>COA</reqtype>
        <transtype>05</transtype>
      </request>
      <response>
        <responseCode>01</responseCode>
        <responseMessage>settlement succeeded</responseMessage>
      </response>
    </transaction>
  </body>
</paymentService>
    RESPONSE
  end

  def post_xml_capture_failed_false_authorization
    <<-RESPONSE
<?xml version='1.0' encoding='UTF-8'?>
<paymentService version='1'>
  <body merchantId='1000011011' testOnly='yes' status='accepted'>
    <transaction refno='628a069429b4453bb2' trxStatus='error'>
      <request>
        <amount>100</amount>
        <currency>CHF</currency>
        <authorizationCode>800247117</authorizationCode>
        <reqtype>COA</reqtype>
        <transtype>05</transtype>
      </request>
      <error>
        <errorCode>-80</errorCode>
        <errorMessage>UPP record not found</errorMessage>
        <errorDetail/>
      </error>
    </transaction>
  </body>
</paymentService>
    RESPONSE
  end

  def post_xml_capture_failed_already_settled
    <<-RESPONSE
<?xml version='1.0' encoding='UTF-8'?>
<paymentService version='1'>
  <body merchantId='1000011011' testOnly='yes' status='accepted'>
    <transaction refno='628a069429b4453bb2' trxStatus='error'>
      <request>
        <amount>100</amount>
        <currency>CHF</currency>
        <authorizationCode>800247117</authorizationCode>
        <reqtype>COA</reqtype>
        <transtype>05</transtype>
      </request>
      <error>
        <errorCode>1010</errorCode>
        <errorMessage>cannot be settled</errorMessage>
        <errorDetail>trx has been settled already</errorDetail>
      </error>
    </transaction>
  </body>
</paymentService>
    RESPONSE
  end

  def post_xml_invalid_login
    <<-RESPONSE
<?xml version='1.0' encoding='UTF-8'?>
<paymentService version='1'>
  <body merchantId='1000011011' testOnly='yes' status='accepted'>
    <transaction refno='628a069429b4453bb2' trxStatus='error'>
      <request>
        <amount>100</amount>
        <currency>CHF</currency>
        <authorizationCode>800247117</authorizationCode>
        <reqtype>COA</reqtype>
        <transtype>05</transtype>
      </request>
      <error>
        <errorCode>2022</errorCode>
        <errorMessage>invalid value</errorMessage>
        <errorDetail>merchantId()</errorDetail>
      </error>
    </transaction>
  </body>
</paymentService>
    RESPONSE
  end

  def post_xml_void_accepted
    <<-RESPONSE
<?xml version='1.0' encoding='UTF-8'?>
<paymentService version='1'>
  <body merchantId='1000011011' testOnly='yes' status='accepted'>
    <transaction refno='628a069429b4453bb2' trxStatus='response'>
      <request>
        <amount>100</amount>
        <currency>CHF</currency>
        <authorizationCode>800247117</authorizationCode>
        <reqtype>DOA</reqtype>
        <transtype>05</transtype>
      </request>
      <response>
        <responseCode>01</responseCode>
        <responseMessage>cancellation succeeded</responseMessage>
      </response>
    </transaction>
  </body>
</paymentService>
    RESPONSE
  end

  def post_xml_void_failed_not_found
    <<-RESPONSE
<?xml version='1.0' encoding='UTF-8'?>
<paymentService version='1'>
  <body merchantId='1000011011' testOnly='yes' status='accepted'>
    <transaction refno='628a069429b4453bb2' trxStatus='error'>
      <request>
        <amount>100</amount>
        <currency>CHF</currency>
        <authorizationCode>800247117</authorizationCode>
        <reqtype>DOA</reqtype>
        <transtype>05</transtype>
      </request>
      <error>
        <errorCode>2022</errorCode>
        <errorMessage>invalid value</errorMessage>
        <errorDetail> authorizationCode,</errorDetail>
      </error>
    </transaction>
  </body>
</paymentService>
    RESPONSE
  end

end
