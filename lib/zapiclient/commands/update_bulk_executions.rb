
require 'json'
require_relative './command'

module Zapiclient::Commands

  class UpdateBulkExecutions < Command

    BASE_URL = '/public/rest/api/1.0/executions'

    attr_accessor :status
    attr_accessor :executionList

    def initialize()
      super(BASE_URL)
      @executionList = []
      @status = -1   # Unexecuted
      puts __FILE__ + (__LINE__).to_s + " [UpdateBulkExecutions.init]" if Zapiclient::Utils.instance.isVerbose?
    end

    def sendRequest()
      myClaim = Atlassian::Jwt.build_claims(getAccessKey, getFullUrl, 'post', getBaseUrl())
      @jwt = 'JWT ' + JWT.encode(myClaim, getSecretKey)

      headers = {
          :content_type => 'application/json',
          :authorization => @jwt,
          :zapiaccesskey => getAccessKey()
      }

      @request = {
          "executions":@executionList,
          "status":@status,
          "clearDefectMappingFlag":false,
          "testStepStatusChangeFlag":true,
          "stepStatus":-1
      }

      @response = RestClient.post(getFullUrl,
                                  @request.to_json,
                                  headers)
    end


    def execute(list, status=-1)
      puts "Execution List: #{list}" if Zapiclient::Utils.instance.isVerbose?
      @executionList = list
      @status = status
      @response = sendRequest()
    end

  end

end
