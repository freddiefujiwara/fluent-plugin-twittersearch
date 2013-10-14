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
        config_param :count,   :integer
        config_param :result_type, :string

        attr_reader :twitter

        def initialize
            super
            require "twitter"
        end

        def configure(config)
            super
            Twitter.configure do |cnf|   
                cnf.consumer_key    = @consumer_key
                cnf.consumer_secret = @consumer_secret
            end
            @twitter = Twitter::Client.new(
                                             :oauth_token => @oauth_token,
                                             :oauth_token_secret => @oauth_token_secret
                                            )
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
