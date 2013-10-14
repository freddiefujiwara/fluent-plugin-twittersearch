require 'fluent/test'
require 'json'
require 'fluent/plugin/in_twittersearch'

class FileInputTest < Test::Unit::TestCase
    def setup
        Fluent::Test.setup

        @d = create_driver %[
            consumer_key        CONSUMER_KEY
            consumer_secret     CONSUMER_SECRET
            oauth_token         OAUTH_TOKEN
            oauth_token_secret  OAUTH_TOKEN_SECRET
            tag                 input.twitter
            keyword             sampling
        ]
    end

    def create_driver(config = CONFIG)
        Fluent::Test::OutputTestDriver.new(Fluent::TwittersearchInput).configure(config)
    end

    def test_configure
        d = create_driver %[
          consumer_key        CONSUMER_KEY
          consumer_secret     CONSUMER_SECRET
          oauth_token         OAUTH_TOKEN
          oauth_token_secret  OAUTH_TOKEN_SECRET
          tag                 input.twitter
          keyword             sampling
        ]
        d.instance.inspect
        assert_equal 'CONSUMER_KEY', d.instance.consumer_key
        assert_equal 'CONSUMER_SECRET', d.instance.consumer_secret
        assert_equal 'OAUTH_TOKEN', d.instance.oauth_token
        assert_equal 'OAUTH_TOKEN_SECRET', d.instance.oauth_token_secret
    end
end
