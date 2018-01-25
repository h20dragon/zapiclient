require 'json'
require_relative './command'

module Zapiclient::Commands

  class ServerInfo < Command

    BASE_URL = '/public/rest/api/1.0/serverinfo'

    def initialize()
      super(BASE_URL)
      @debug = false
      puts __FILE__ + (__LINE__).to_s + " [ServerInfo.init]"
    end

    def sendRequest()
      puts __FILE__ + (__LINE__).to_s + " [ServerInfo.sendRequest]: " if @debug

      @jwt = jwt()

      headers = {
          :content_type => 'application/json',
          :authorization => @jwt,
          :zapiaccesskey => getAccessKey()
      }

      @response = RestClient.get 'https://prod-api.zephyr4jiracloud.com/connect/public/rest/api/1.0/serverinfo', headers
      parsed = JSON.parse(@response)
      return parsed
    end

    def execute()
      puts __FILE__ + (__LINE__).to_s + " [SourceInfo.execute]" if @debug
      @response = sendRequest()
      puts JSON.pretty_generate @response if @debug
      @response
    end

  end

end