# Description: Get a Cycle's test steps results for a provided ISSUE (Testcase)
# Example:
# {
# "stepResults": [
#     {
#         "id": "0001517426053639-242ac112-0001",
#         "executedOn": 1517426520819,
#         "executedBy": "pkim",
#         "executionId": "0001517402203431-242ac112-0001",
#         "stepId": "0001517408645178-242ac112-0001",
#         "status": {
#             "name": "PASS",
#             "id": 1,
#             "description": "Test was executed and passed successfully.",
#             "color": "#75B000",
#             "type": 0
#         },
#         "issueId": 45699,
#         "modifiedBy": "pkim",
#         "executionIndex": "0001517402203431-242ac112-0001",
#         "issueIndex": 45699,
#         "executionStatusIndex": 1
#     },
#     {
#         "id": "0001517426053667-242ac112-0001",
#         "executionId": "0001517402203431-242ac112-0001",
#         "stepId": "0001517406322403-242ac112-0001",
#         "status": {
#             "name": "UNEXECUTED",
#             "id": -1,
#             "description": "The test has not yet been executed.",
#             "color": "#A0A0A0",
#             "type": 0
#         },
#         "issueId": 45699,
#         "modifiedBy": "pkim",
#         "executionIndex": "0001517402203431-242ac112-0001",
#         "issueIndex": 45699,
#         "executionStatusIndex": -1
#     }
# ],
#     "executionStatus": {
#     "-1": {
#         "name": "UNEXECUTED",
#         "id": -1,
#         "description": "The test has not yet been executed.",
#         "color": "#A0A0A0",
#         "type": 0
#     },
#     "1": {
#         "name": "PASS",
#         "id": 1,
#         "description": "Test was executed and passed successfully.",
#         "color": "#75B000",
#         "type": 0
#     },
#     "2": {
#         "name": "FAIL",
#         "id": 2,
#         "description": "Test was executed and failed.",
#         "color": "#CC3300",
#         "type": 0
#     },
#     "3": {
#         "name": "WIP",
#         "id": 3,
#         "description": "Test execution is a work-in-progress.",
#         "color": "#F2B000",
#         "type": 0
#     },
#     "4": {
#         "name": "BLOCKED",
#         "id": 4,
#         "description": "The test execution of this test was blocked for some reason.",
#         "color": "#6693B0",
#         "type": 0
#     }
# }
# }


require 'json'
require_relative './command'
require_relative '../base/../base/cycles'

module Zapiclient::Commands

  class GetStepResults < Command

    BASE_URL = '/public/rest/api/1.0/stepresult/search?executionId={EXECUTION_ID}&issueId={ISSUE_ID}'

    def initialize(executionId, issueId)
      @debug = true
      puts __FILE__ + (__LINE__).to_s + " [initialize]" if Zapiclient::Utils.instance.isVerbose?
      tmpStr = BASE_URL.sub('{EXECUTION_ID}', executionId)
      tmpStr = tmpStr.sub('{ISSUE_ID}', issueId)

      setUri(tmpStr)

      puts __FILE__ + (__LINE__).to_s + " [GetStepResults.init]: #{tmpStr}" if Zapiclient::Utils.instance.isVerbose?
    end

    def dump()
      puts __FILE__ + (__LINE__).to_s + " [GetStepResults.dump]"
      puts JSON.pretty_generate @response
    end

    def sendRequest()
      puts __FILE__ + (__LINE__).to_s + " [GetStepResults.sendRequest]: "  if Zapiclient::Utils.instance.isVerbose?

      @jwt = jwt()

      headers = {
          :content_type => 'text/plain',
          :authorization => @jwt,
          :zapiaccesskey => getAccessKey()
      }

      @response = RestClient.get(getBaseUrl + @uri, headers)
      parsed = JSON.parse(@response)

      if Zapiclient::Utils.instance.isVerbose?
        puts __FILE__ + (__LINE__).to_s + " [getStepResults.execute()]:"
        puts JSON.pretty_generate parsed
      end

      return parsed
    end

    def execute()
      puts __FILE__ + (__LINE__).to_s + " [GetStepResults.execute]" if Zapiclient::Utils.instance.isVerbose?
      @response = sendRequest()

      if Zapiclient::Utils.instance.isVerbose?
        puts JSON.pretty_generate @response
      end

      return @response
    end

  end

end