module Fluent
    class TwittersearchError < StandardError
    end
    class TwittersearchInput < Input
        Plugin.register_input('twittersearch', self)
        config_param :consumer_key, :string
        config_param :consumer_secret, :string
        config_param :oauth_token, :string
        config_param :oauth_token_secret, :string
        config_param :tag, :string
        config_param :keyword, :string

        def initialize
            super
            require 'json'
            require 'net/http'
            @urls = []
        end

        def start
            super
            @thread = Thread.new(&method(:run))
        end

        def run
            loop {
                @urls.each do |url|
                    Engine.emit @tag, Engine.now , crawl(url)
                    sleep @sleep if @sleep.to_i > 0
                end
            }
        end

        def crawl(url)
            response = Net::HTTP.get_response(URI.parse(url))
            case response
            when Net::HTTPSuccess
                return JSON.parse response.body
            end
            raise Fluent::TwittersearchError.new
        end

        def shutdown
            Thread.kill(@thread)
        end
    end
end
