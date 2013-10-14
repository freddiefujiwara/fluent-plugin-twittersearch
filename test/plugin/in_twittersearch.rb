require 'fluent/test'
require 'json'
require 'fluent/plugin/in_twittersearch'

class FileInputTest < Test::Unit::TestCase
    def setup
        Fluent::Test.setup

        @d = create_driver %[
            consumer_key        T5dTrSxS3oXqBbaoYZERw
            consumer_secret     Trg3qrO7dUSkKZeGxgjmi3B11JuFhjwhiWIkwWKDe0
            oauth_token         1960044126-heQQwLkiqoTj7uEJAVy0WDUZEEZDJfQqk7C4JIz
            oauth_token_secret  r0JZ258nTeYzfJ6PZcpD8Pd1ulgawXFt2fP5J5lzZ8
            tag                 input.twitter
            keyword             rakuten
            count               1
            run_interval            60
            result_type         recent
        ]
    end

    def create_driver(config = CONFIG)
        Fluent::Test::OutputTestDriver.new(Fluent::TwittersearchInput).configure(config)
    end

    def test_configure
        d = create_driver %[
          consumer_key        T5dTrSxS3oXqBbaoYZERw
          consumer_secret     Trg3qrO7dUSkKZeGxgjmi3B11JuFhjwhiWIkwWKDe0
          oauth_token         1960044126-heQQwLkiqoTj7uEJAVy0WDUZEEZDJfQqk7C4JIz
          oauth_token_secret  r0JZ258nTeYzfJ6PZcpD8Pd1ulgawXFt2fP5J5lzZ
          tag                 input.twitter
          keyword             rakuten
          count               1
          run_interval            60
          result_type         recent
        ]
        d.instance.inspect
        assert_equal 'T5dTrSxS3oXqBbaoYZERw', d.instance.consumer_key
        assert_equal 'Trg3qrO7dUSkKZeGxgjmi3B11JuFhjwhiWIkwWKDe0', d.instance.consumer_secret
        assert_equal '1960044126-heQQwLkiqoTj7uEJAVy0WDUZEEZDJfQqk7C4JIz', d.instance.oauth_token
        assert_equal 'r0JZ258nTeYzfJ6PZcpD8Pd1ulgawXFt2fP5J5lzZ', d.instance.oauth_token_secret
        assert_equal 'input.twitter', d.instance.tag
        assert_equal 'rakuten', d.instance.keyword
        assert_equal 1, d.instance.count
        assert_equal 60, d.instance.run_interval
        assert_equal 'recent', d.instance.result_type
        assert_not_nil d.instance.twitter
        assert_equal Twitter::Client , d.instance.twitter.class 
        assert_raise Twitter::Error::Unauthorized do
            d.instance.twitter.search(d.instance.keyword,
                                    :count => d.instance.count,
                                    :result_type => d.instance.result_type)
        end
        d = create_driver %[
          consumer_key        T5dTrSxS3oXqBbaoYZERw
          consumer_secret     Trg3qrO7dUSkKZeGxgjmi3B11JuFhjwhiWIkwWKDe0
          oauth_token         1960044126-heQQwLkiqoTj7uEJAVy0WDUZEEZDJfQqk7C4JIz
          oauth_token_secret  r0JZ258nTeYzfJ6PZcpD8Pd1ulgawXFt2fP5J5lzZ8
          tag                 input.twitter
          keyword             rakuten
          count               1
          run_interval            60
          result_type         recent
        ]
        assert_equal 1, d.instance.twitter.search(d.instance.keyword,
                                :count => d.instance.count,
                                :result_type => d.instance.result_type).results.count
    end

    def test_search
        d = create_driver %[
          consumer_key        T5dTrSxS3oXqBbaoYZERw
          consumer_secret     Trg3qrO7dUSkKZeGxgjmi3B11JuFhjwhiWIkwWKDe0
          oauth_token         1960044126-heQQwLkiqoTj7uEJAVy0WDUZEEZDJfQqk7C4JIz
          oauth_token_secret  r0JZ258nTeYzfJ6PZcpD8Pd1ulgawXFt2fP5J5lzZ8
          tag                 input.twitter
          keyword             rakuten
          count               1
          run_interval            60
          result_type         recent
        ]
        tweets = d.instance.search
        tweets.each do |tweet|
            [:created_at,
             :id,
             :text,
             :retweet_count,
             :favorite_count,
             :screen_name,
             :name,
             :profile_image_url,
             :profile_image_url_https].each do |key|
                assert_not_nil tweet[key]
             end
        end
    end
end
