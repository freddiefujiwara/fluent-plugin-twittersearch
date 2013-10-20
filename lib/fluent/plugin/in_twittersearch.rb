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
        config_param :keyword, :string,:default => nil
        config_param :hashtag, :string,:default => nil
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
            raise Fluent::ConfigError.new if @keyword.nil? and @hashtag.nil?
        end

        def start
            super
            @thread = Thread.new(&method(:run))
        end

        def search
            tweets = []
            @twitter.search(@keyword.nil? ? "##{@hashtag}" : @keyword,
                                    :count => @count,
                                    :result_type => @result_type).results.reverse.map do |result|

                tweet = Hash.new
                [:id,:retweet_count,:favorite_count].each do |key|
                    tweet.store(key.to_s, result[key].to_s)
                end
                [:screen_name,:profile_image_url,:profile_image_url_https].each do |key|
                    tweet.store(key.to_s, result.user[key].to_s)
                end
                tweet.store('created_at', result[:created_at].strftime("%Y-%m-%d %H:%M:%S"))
                tweet.store('user_id', result.user[:id])
                tweet.store('text',result.text.force_encoding('utf-8'))
                tweet.store('name',result.user.name.force_encoding('utf-8'))
                tweets << tweet
            end
            tweets
        end

        def run
            loop do
                search.each do |tweet|
                    Engine.emit @tag,Engine.now,tweet
                end
                sleep @run_interval
            end
        end

        def shutdown
            Thread.kill(@thread)
        end
    end
end
