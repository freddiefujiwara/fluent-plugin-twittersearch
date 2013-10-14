require 'fluent/test'
require 'json'
require 'fluent/plugin/in_twittersearch'

class FileInputTest < Test::Unit::TestCase
    def setup
        Fluent::Test.setup

        @d = create_driver %[
            url   http://pipes.yahoo.com/pipes/pipe.run?_id=c9b9df32b4c3e0ccbe4547ae7e00ed2f&_render=json&condition=d7D&genre=__GENRE__&page=__PAGE__
            rules   {'__PAGE__' => (1..10),'__GENRE__' => [1,100533]} 
            sleep       1
            tag     input.json
        ]
        @time = Time.now.to_i
    end

    def create_driver(config = CONFIG)
        Fluent::Test::OutputTestDriver.new(Fluent::TwittersearchInput).configure(config)
    end

    def test_configure
        assert_equal 'http://pipes.yahoo.com/pipes/pipe.run?_id=c9b9df32b4c3e0ccbe4547ae7e00ed2f&_render=json&condition=d7D&genre=__GENRE__&page=__PAGE__'   , @d.instance.url
        assert_equal @d.instance.rules.size, 20 #10(page) x 2(genre)
        assert_equal 1           , @d.instance.sleep
        assert_equal 'input.json', @d.instance.tag
        [ %[
                url   hoge
                rules   {'__PAGE__' => (1..10)}
                sleep       1
                tag     input.json
            ], #url wrong
          %[
                url   ftp://hoge.com
                rules   {'__PAGE__' => (1..10)}
                sleep       1
                tag     input.json
            ], #url must start at http
          %[
                url   http://hoge.com
                sleep       1
                rules   {'__PAGE__' => (1..10)}
            ], #no tag
          %[
                url   http://hoge.com
                sleep       1
                rules   {__PAGE__}
                tag     input.json
            ], #rules must be {'key' => array}
          %[
                url   http://hoge.com
                sleep       1
                rules   (1..2)
                tag     input.json
            ], #rules must be {'key' => array}
        ].each do |config|
            assert_raise Fluent::ConfigError do
                create_driver config
            end
        end
    end

    def test_urls
        assert_equal @d.instance.urls.size, 20
        index = 0
        (1..10).each do |page|
            [1,100533].each do |genre|
                assert_equal "http://pipes.yahoo.com/pipes/pipe.run?_id=c9b9df32b4c3e0ccbe4547ae7e00ed2f&_render=json&condition=d7D&genre=#{genre}&page=#{page}", @d.instance.urls[index]

                index += 1
            end
        end
    end

    def test_crawls
        for page in 1..1
            url = "http://pipes.yahoo.com/pipes/pipe.run?_id=c9b9df32b4c3e0ccbe4547ae7e00ed2f&_render=json&condition=d7D&genre=100533&page=#{page}"
            response = @d.instance.crawl url
            assert_not_nil response
            assert_equal response['count'], 30
            assert_equal response['value']['items'].size, 30
            response['value']['items'].each do |item|
                #content
                assert item['author']['content'].to_f >= 0.0
                assert item['author']['content'].to_f <= 5.0

                #link
                assert_equal URI.parse(item['link']).scheme, 'http' if item['link']
                #title
                assert_equal URI.parse(item['title']).scheme, 'http' if item['title']

                #description
                assert_not_nil item['description']

                #pubDate
                assert_not_nil item['pubDate']['content']
            end
        end

        #parse error
        assert_raise JSON::ParserError do
            @d.instance.crawl 'http://www.rakuten.co.jp'
        end

        #404 Not found
        assert_raise Fluent::TwittersearchError do
            @d.instance.crawl 'http://www.google.com/404'
        end
    end
end
