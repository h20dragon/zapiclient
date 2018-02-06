require 'json'
require_relative './command'

module Zapiclient::Commands

  class AddTestCycle < Command

    BASE_URL = '/public/rest/api/1.0/executions/add/cycle/{CYCLE_ID}'

    def initialize(opts)
      @cycleId = opts[:cycleId]
      @projectId = opts[:projectId]
      @versionId = opts[:versionId]
      tmpStr = BASE_URL.sub('{CYCLE_ID}', @cycleId)
      setUri(tmpStr)
    end


    def sendRequest()
      myClaim = Atlassian::Jwt.build_claims(getAccessKey, getFullUrl, 'post', getBaseUrl())
      @jwt = 'JWT ' + JWT.encode(myClaim, getSecretKey)

      headers = {
          :content_type => 'application/json',
          :authorization => @jwt,
          :zapiaccesskey => getAccessKey()
      }
      @response = RestClient.post(getFullUrl,
                                  @request.to_json,
                                  headers)

      return @response
    end

    def execute(list)

      issueList = list.split(/,/).map { |s| s.strip }

      @request = {
                  "projectId": @projectId,
                  "versionId": @versionId,
                  "issues": issueList,
                  "method": 1
               }

      @response = sendRequest()

      if Zapiclient::Utils.instance.isVerbose?
        puts __FILE__ + (__LINE__).to_s + "== [AddTestsToCycle Response] =="
        puts  @response
      end

      @response
    end

  end

end