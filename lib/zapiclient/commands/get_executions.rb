require 'json'
require_relative './command'

module Zapiclient::Commands

  class GetExecutions < Command

    BASE_URL = '/public/rest/api/1.0/executions/search?executionId={EXECUTION_ID}'

    def initialize(opts)
      @executionId = opts[:executionId].to_s
      tmpStr = BASE_URL.sub('{EXECUTION_ID}', @executionId)

      puts __FILE__ + (__LINE__).to_s + " tmpUrl => #{tmpStr}"
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

    def execute()
      @request = {"maxRecords" => "20",
                  "offset" => "0",
                  "zql": "field=\"value\""}

      @response = sendRequest()

      if Zapiclient::Utils.instance.isVerbose?
        puts __FILE__ + (__LINE__).to_s + "== [AddTestsToCycle Response] =="
        puts  @response
      end

      @response
    end

  end

end