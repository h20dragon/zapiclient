require 'json'
require_relative './command'

module Zapiclient::Commands

  class SearchCycles < Command

    #BASE_URL = '/public/rest/api/1.0/cycles/search?projectId=13301&versionId=-1'
    BASE_URL = '/public/rest/api/1.0/cycles/search?projectId={PROJECT_ID}&versionId={VERSION_ID}'
    # uri = 'https://prod-api.zephyr4jiracloud.com/connect/public/rest/api/1.0/serverinfo'


    def initialize(opts={:projectId => '-1', :versionId => '-1'})
     # super(BASE_URL)
      tmpStr = BASE_URL.sub('{PROJECT_ID}', opts[:projectId])
      tmpStr = tmpStr.sub('{VERSION_ID}', opts[:versionId])


      puts "[tmpStr]: #{tmpStr}" if @debug

      setUri(tmpStr)

      puts __FILE__ + (__LINE__).to_s + " [SearchCycles.init]" if @debug
    end


    def sendRequest()
      puts __FILE__ + (__LINE__).to_s + " [SearchCycles.sendRequest]: " if @debug

      @jwt = jwt()

      headers = {
          :content_type => 'text/plain',
          :authorization => @jwt,
          :zapiaccesskey => getAccessKey()
      }

      @response = RestClient.get(getBaseUrl + @uri, headers)

      # We are expecting a JSON formatted string (response)

      if @debug
        # puts "RESPONSE => #{@response.class.to_s}"
        # puts "==> " + @response.methods.sort.to_s
      end

      parsed = JSON.parse(@response)


      return parsed
    end

    def execute()
      puts __FILE__ + (__LINE__).to_s + " [SourceInfo.execute]"
      @response = sendRequest()

      puts JSON.pretty_generate @response
    end

  end

end