require 'test_helper'

class DatatransTest < Test::Unit::TestCase
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

  def test_supported_countries
    assert_equal ['CH'], DatatransGateway.supported_countries
  end

  def test_supported_card_types
    assert_equal [ :visa, :master, :american_express, :diners_club ], DatatransGateway.supported_cardtypes
  end

end
