

require 'json'
require_relative './command'
require_relative '../base/../base/cycles'

module Zapiclient::Commands

  class SearchCycle < Command

    BASE_URL = '/public/rest/api/1.0/cycle/{CYCLE_ID}?versionId={VERSION_ID}&projectId={PROJECT_ID}&expand=executionSummaries'

    def initialize(projectId, versionId, cycleId)
      # super(BASE_URL)
      @projectId = projectId
      tmpStr = BASE_URL.sub('{PROJECT_ID}', projectId)
      tmpStr = tmpStr.sub('{VERSION_ID}', versionId)
      tmpStr = tmpStr.sub('{CYCLE_ID}', cycleId)

      @debug = false

      setUri(tmpStr)

      puts __FILE__ + (__LINE__).to_s + " [SearchCycle.init]" if @debug
    end

    def dump()
      puts __FILE__ + (__LINE__).to_s + " [SearchCycle.dump]"
      puts JSON.pretty_generate @response
    end

    def sendRequest()
      puts __FILE__ + (__LINE__).to_s + " [SearchCycle.sendRequest]: " if @debug

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

    def execute()
      puts __FILE__ + (__LINE__).to_s + " [SearchCycles.execute]" if @debug
      @response = sendRequest()

      if @debug || true
        puts __FILE__ + (__LINE__).to_s + " [searchCycle]:"
        puts JSON.pretty_generate @response
      end

      @cycles = Zapiclient::Cycle.new(@response, @projectId)

    #  return @cycles
    end

  end

end