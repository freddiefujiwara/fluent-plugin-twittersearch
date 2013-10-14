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
        config_param :run_interval,   :integer
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

        def search
            tweets = []
            @twitter.search(@keyword,
                                    :count => @count,
                                    :result_type => @result_type).results.reverse.map do |result|
                tweet = {}
                [:created_at,:id,:text,:retweet_count,:favorite_count].each do |key|
                    tweet[key] = result[key]
                end
                [:id,:screen_name,:name,:profile_image_url,:profile_image_url_https].each do |key|
                    tweet[key] = result.user[key]
                end
                tweet[:time] = Engine.now
                tweets << tweet
            end
            tweets
        end
        def run
            loop do
                search.each do |tweet|
                    Engine.emit tweet[:time],@tag, tweet
                end
                sleep @run_interval
            end
        end

        def shutdown
            Thread.kill(@thread)
        end
    end
end
