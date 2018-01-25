

require 'benchmark'

require 'pp'
require 'rest_client'
require 'atlassian/jwt'
require 'digest'

module Zapiclient::Commands

  ZAPI_BASE_URL = 'https://prod-api.zephyr4jiracloud.com/connect'

  class Command

    attr_accessor :claim
    attr_accessor :debug
    attr_accessor :description
    attr_accessor :uri
    attr_accessor :fullUri
    attr_accessor :jwt
    attr_accessor :response



    def makeClaim()
      @claim = {}
      @claim[:user] = ENV['ZAPI_USER']
      @claim[:baseUrl] = 'https://prod-api.zephyr4jiracloud.com/connect'
      @claim[:secretKey] = ENV['ZAPI_SECRET_KEY']
      @claim[:accessKey] = ENV['ZAPI_ACCESS_KEY']
    end

    def getAccessKey()
      return @claim[:accessKey]
    end

    def getFullUrl()
      getBaseUrl + @uri
    end

    def getBaseUrl()
      return @claim[:baseUrl]
    end

    def getSecretKey()
      return @claim[:secretKey]
    end

    def _setup()
      @debug = false
      @jwt = nil
      @response = nil
      makeClaim()
    end

    def initialize(_uri=nil)
      @uri = _uri

      puts __FILE__ + (__LINE__).to_s + "  [Command.init]: #{@uri}" if @debug
      _setup()
    end

    def setUri(u)
      @uri = u
      _setup()
    end

    def run(opts) # (_drv=nil, _dut=nil)
      puts __FILE__ + (__LINE__).to_s + " [Command.init]: run" if @debug
    end


    def jwt(httpmethod='get')
      puts __FILE__ + (__LINE__).to_s + " [Command.jwt]: " + @uri  if @debug
      return Zapiclient::Commands::Command::generateJwt(@uri, @claim, httpmethod)
    end

    def self.generateJwt(uri, claim, httpmethod='get')
      puts __FILE__ + (__LINE__).to_s + " [Command,generateJwt]: " + uri.to_s  if @debug

      # Examples
      #    uri = 'https://prod-api.zephyr4jiracloud.com/connect/public/rest/api/1.0/cycles/search?projectId=13301&versionId=-1';
      fullUri = ZAPI_BASE_URL + uri


      hash_lib = Digest::SHA256.new
      hash_lib.update(httpmethod + fullUri)

      encodedQsh = hash_lib = Digest::SHA256.hexdigest('hex')

      myClaim = Atlassian::Jwt.build_claims(claim[:accessKey], fullUri, httpmethod, claim[:baseUrl])
      jwt = 'JWT ' + JWT.encode(myClaim, claim[:secretKey])
    end

  end

end

