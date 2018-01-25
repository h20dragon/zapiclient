require 'json'
require_relative './command'
require_relative '../base/../base/cycles'

module Zapiclient::Commands

  class SearchCycles < Command

    BASE_URL = '/public/rest/api/1.0/cycles/search?projectId={PROJECT_ID}&versionId={VERSION_ID}&expand=executionSummaries'


    def initialize(opts={:projectId => '-1', :versionId => '-1'})
     # super(BASE_URL)
      @projectId = opts[:projectId]
      tmpStr = BASE_URL.sub('{PROJECT_ID}', opts[:projectId])
      tmpStr = tmpStr.sub('{VERSION_ID}', opts[:versionId])

      @debug = false
      puts "[tmpStr]: #{tmpStr}" if @debug

      setUri(tmpStr)

      puts __FILE__ + (__LINE__).to_s + " [SearchCycles.init]" if @debug
    end

    def dump()
      puts __FILE__ + (__LINE__).to_s + " [SearchCycles.dump]"
      puts JSON.pretty_generate @response
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

      parsed = JSON.parse(@response)

      return parsed
    end

    # Returns Cycles
    def execute()
      puts __FILE__ + (__LINE__).to_s + " [SearchCycles.execute]" if @debug
      @response = sendRequest()

      puts JSON.pretty_generate @response if @debug

      @cycles = Zapiclient::Cycles.new(@response, @projectId)

      return @cycles
    end

  end

end