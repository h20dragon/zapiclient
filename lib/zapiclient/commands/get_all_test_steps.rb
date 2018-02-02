# Description: Returns an array of test steps (does not depend on Cycle)
#
# Example:
#
# [
#     {
#         "id": "0001517406322403-242ac112-0001",
#         "orderId": 1,
#         "issueId": 45699,
#         "step": "test_add_big_point.test_add_big_point",
#         "result": "Pass",
#         "createdBy": "pkim",
#         "createdOn": 1517406322403,
#         "lastModifiedOn": 1517406322403,
#         "attachments": [
#
#         ]
#     },
#     {
#         "id": "0001517408645178-242ac112-0001",
#         "orderId": 2,
#         "issueId": 45699,
#         "step": "test_plot2d_layer_order.test_track_order",
#         "createdBy": "pkim",
#         "createdOn": 1517408645178,
#         "lastModifiedOn": 1517408645178,
#         "attachments": [
#
#         ]
#     }
# ]



require 'json'
require_relative './command'

module Zapiclient::Commands

  class GetAllTestSteps < Command

    BASE_URL = '/public/rest/api/1.0/teststep/{ISSUE_ID}?projectId={PROJECT_ID}'

    def initialize(opts)
      @debug = Zapiclient::Utils.instance.isVerbose?
      @projectId = opts[:projectId]
      tmpStr = BASE_URL.sub('{PROJECT_ID}', opts[:projectId])
      tmpStr = tmpStr.sub('{ISSUE_ID}', opts[:issueId])
      setUri(tmpStr)
    end


    def sendRequest()
      @jwt = jwt()
      headers = {
          :content_type => 'application/json',
          :authorization => @jwt,
          :zapiaccesskey => getAccessKey()
      }
      @response = RestClient.get(getBaseUrl + @uri, headers)
      return JSON.parse(@response)
    end

    def execute()
      @response = sendRequest()

      if Zapiclient::Utils.instance.isVerbose?
        puts __FILE__ + (__LINE__).to_s + "== [GetAllTestSteps Response] =="
        puts JSON.pretty_generate @response
      end

      @response
    end

  end

end