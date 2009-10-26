module Weary
  class Resource
    attr_accessor :name, :domain, :with, :requires, :via, :format, :url, :authenticates, :follows, :headers, :oauth, :access_token
    
    def initialize(name)
      self.name = name
      self.via = :get
      self.authenticates = false
      self.follows = true
      self.with = []
      self.requires = []
      self.oauth = false
    end
    
    def name=(resource_name)
      resource_name = resource_name.to_s unless resource_name.is_a?(String)
      @name = resource_name.downcase.strip.gsub(/\s/,'_')
    end
    
    def via=(http_verb)
      @via = case http_verb
        when *Methods[:get]
          :get
        when *Methods[:post]
          :post
        when *Methods[:put]
          :put
        when *Methods[:delete]
          :delete
        else
          raise ArgumentError, "#{http_verb} is not a supported method"
      end
    end
    
    def format=(type)
      type = type.downcase if type.is_a?(String)
      @format = case type
        when *ContentTypes[:json]
          :json
        when *ContentTypes[:xml]
          :xml
        when *ContentTypes[:html]
          :html
        when *ContentTypes[:yaml]
          :yaml
        when *ContentTypes[:plain]
          :plain
        else
          raise ArgumentError, "#{type} is not a recognized format."
      end
    end
        
    def with=(params)
      if params.is_a?(Hash)
        @requires.each { |key| params[key] = nil unless params.has_key?(key) }
        @with = params
      else
        if @requires.nil?
          @with = params.collect {|x| x.to_sym}
        else
          @with = params.collect {|x| x.to_sym} | @requires
        end
      end
    end
    
    def requires=(params)
      if @with.is_a?(Hash)
        params.each { |key| @with[key] = nil unless @with.has_key?(key) }
        @requires = params.collect {|x| x.to_sym}
      else
        @with = @with | params.collect {|x| x.to_sym}
        @requires = params.collect {|x| x.to_sym}
      end
    end
    
    def url=(pattern)
      if pattern.index("<domain>")
        raise StandardError, "Domain flag found but the domain is not defined" if @domain.nil?
        pattern = pattern.gsub("<domain>", @domain)
      end
      pattern = pattern.gsub("<resource>", @name)
      pattern = pattern.gsub("<format>", @format.to_s)
      @url = pattern
    end
    
    def oauth=(bool)
      @authenticates = false if bool
      @oauth = if bool
        true
      else
        false
      end
    end
    
    def authenticates=(bool)
      @oauth = false if bool
      @authenticates = if bool
        true
      else
        false
      end
    end
    
    def authenticates?
      @authenticates
    end
    
    def oauth?
      @oauth
    end
    
    def access_token=(token)
      raise ArgumentError, "Token needs to be an OAuth::AccessToken object" unless token.is_a?(OAuth::AccessToken)
      @oauth = true
      @access_token = token
    end
    
    def follows_redirects?
      if @follows
        true
      else
        false
      end
    end

    def to_hash
      {@name.to_sym => { :via => @via,
                         :with => @with,
                         :requires => @requires,
                         :follows => follows_redirects?,
                         :authenticates => authenticates?,
                         :format => @format,
                         :url => @url,
                         :domain => @domain,
                         :headers => @headers,
                         :oauth => oauth?,
                         :access_token => @access_token}}
    end
    
  end
end