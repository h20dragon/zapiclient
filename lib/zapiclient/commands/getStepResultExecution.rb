

require 'json'
require_relative './command'
require_relative '../base/../base/cycles'

module Zapiclient::Commands

  class GetStepResultExecution < Command

    BASE_URL = '/public/rest/api/1.0/stepresult/search?executionId={EXECUTION_ID}&issueId={ISSUE_ID}'

    def initialize(executionId, issueId)
      tmpStr = BASE_URL.sub('{EXECUTION_ID}', executionId)
      tmpStr = tmpStr.sub('{ISSUE_ID}', issueId)

      @debug = true

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

      @response = sendRequest()

      if true
        puts __FILE__ + (__LINE__).to_s + " [getStepResultExecution.execute]"
        puts JSON.pretty_generate @response
        puts '*' * 72
      end

      @cycles = Zapiclient::Cycle.new(@response, @projectId)

    #  return @cycles
    end

  end

end