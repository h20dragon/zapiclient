# {
#     "projectId": "13308",
#     "issueId": "45699",
#     "testSteps": [
#         {
#             "id": "0001517406322403-242ac112-0001",
#             "orderId": 1,
#             "issueId": 45699,
#             "step": "test_add_big_point.test_add_big_point",
#             "result": "Pass",
#             "createdBy": "pkim",
#             "createdOn": 1517406322403,
#             "lastModifiedOn": 1517406322403,
#             "attachments": [
#
#             ]
#         },
#         {
#             "id": "0001517408645178-242ac112-0001",
#             "orderId": 2,
#             "issueId": 45699,
#             "step": "test_plot2d_layer_order.test_track_order",
#             "createdBy": "pkim",
#             "createdOn": 1517408645178,
#             "lastModifiedOn": 1517408645178,
#             "attachments": [
#
#             ]
#         }
#     ]
# }

# Description: Update a test step's "data", "comments".  This does not update a test step's "status" (e.g. Pass/Fail/etc)

require 'rest_client'
require 'atlassian/jwt'
require 'digest'
require 'json'
require_relative './command'

module Zapiclient::Commands


  class UpdateTestStep < Command

    BASE_URL = '/public/rest/api/1.0/teststep/{ISSUE_ID}/{ID}?projectId={PROJECT_ID}'
    attr_accessor :updateData

    def initialize( u )

      puts __FILE__ + (__LINE__).to_s + " [initialize]  #{u.class} => #{u.keys}"
      puts JSON.pretty_generate u

      @testSteps = u[:testSteps]

      puts "keys => #{u[:testSteps][0].keys}"

      tmpStr = BASE_URL.sub('{ISSUE_ID}', u[:issueId].to_s)
      tmpStr = tmpStr.sub('{PROJECT_ID}', u[:projectId].to_s)
      tmpStr = tmpStr.sub('{ID}', u[:testSteps][0]['id'].to_s)

      puts __FILE__ + (__LINE__).to_s + " [tmpStr]: #{tmpStr}"
      setUri(tmpStr)

      ts = @testSteps[0]

      @updateData = {}
      @updateData = { "issueId" => ts['issueId'],
                      "id" => ts['id'],
                      "step" => 'test_add_big_point.test_add_big_point',
                      "data" => "Yowza " + Time.now.to_s,
                      "result" => "Woot " + Time.now.to_s,
                      "status" => "1",
                      "comment" => Zapiclient::Utils.instance.getComment()
      }.to_json
    end

    def updateStatus(stepResultId)

      updateStatusUrl = "https://prod-api.zephyr4jiracloud.com/connect/public/rest/api/1.0/stepresult/${stepResultId}"
     # stepResultUpdate: function(stepResultId, issueId, executionId, status) {
     #   let testStepData = { 'status': { 'id': status }, 'issueId': issueId, 'stepId': stepResultId, 'executionId': executionId };
     #   return callZapiCloud('PUT', `https://prod-api.zephyr4jiracloud.com/connect/public/rest/api/1.0/stepresult/${stepResultId}`, 'application/json', ...__ZAPIcreds, testStepData);
     # },
    end

    def _updateExecution()

      httpmethod = 'put'

      myClaim = Atlassian::Jwt.build_claims(getAccessKey(), getFullUrl(),
                                            httpmethod, getBaseUrl())
      jwt = 'JWT ' + JWT.encode(myClaim, getSecretKey())

      headers = {
          :content_type => 'application/json',
          :authorization => jwt,
          :zapiaccesskey =>  ENV['ZAPI_ACCESS_KEY'],
      }

      ## KPP-47   (Cycle: beta1, Version: Release CORE 6.2, Project: Kinetica Playground)
      puts __FILE__ + (__LINE__).to_s + " update => #{@updateData}" if Zapiclient::Utils.instance.isVerbose?
      @response = RestClient.put getFullUrl,
                                @updateData, headers
      @rc = JSON.parse(@response)

      if Zapiclient::Utils.instance.isVerbose?
        puts __FILE__ + (__LINE__).to_s + "== [UpdateExecution Response] =="
        puts JSON.pretty_generate @rc
        puts '=' * 72
      end

      @rc
    end

    def execute(parms=nil)

      client = Zapiclient::Client.new()
      testSteps = client.getAllTestSteps( { :project => 'Kinetica Playground Project', :testcase => 'KPP-54'})

      puts __FILE__ + (__LINE__).to_s + " [UpdateTestSteps.execute.allTestSteps]:"
      puts JSON.pretty_generate testSteps

      updateRc = _updateExecution()

      puts __FILE__ + (__LINE__).to_s + " [UpdateTestSteps.execute.updateExecution]"
      puts JSON.pretty_generate updateRc

      updateRc
    end


  end


end

