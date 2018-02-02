

require 'rest_client'
require 'atlassian/jwt'
require 'digest'
require 'json'
require_relative './command'

module Zapiclient::Commands


  class UpdateExecutionStepResult < Command

    BASE_URL = '/public/rest/api/1.0/stepresult/{STEP_RESULT_ID}'
    attr_accessor :updateData

    def initialize( u )
      tmpStr = BASE_URL.sub('{STEP_RESULT_ID}', u[:stepResultId].to_s)
      puts __FILE__ + (__LINE__).to_s + " initialize() => #{u}" if Zapiclient::Utils.instance.isVerbose?
      setUri(tmpStr)
      puts __FILE__ + (__LINE__).to_s + " URI : #{@uri}" if Zapiclient::Utils.instance.isVerbose?

      @updateData = {
                      "issueId": u[:issueId],
                      "executionId": u[:executionId]
                    }
      puts "[UpdateExecution.init]: " + @updateData if Zapiclient::Utils.instance.isVerbose?
    end



    def _updateExecution(status, comment=nil)
      httpmethod = 'put'

      api = 'https://prod-api.zephyr4jiracloud.com/connect/public/rest/api/1.0/stepresult/0001517426053667-242ac112-0001'
 #     api = 'https://prod-api.zephyr4jiracloud.com/connect/public/rest/api/1.0/stepresult/0001517406322403-242ac112-0001'


      myClaim = Atlassian::Jwt.build_claims(getAccessKey(), getFullUrl,
                                            httpmethod, getBaseUrl())
      jwt = 'JWT ' + JWT.encode(myClaim, getSecretKey())

      headers = {
          :content_type => 'application/json',
          :authorization => jwt,
          :zapiaccesskey =>  ENV['ZAPI_ACCESS_KEY'],
      }

      puts __FILE__ + (__LINE__).to_s + " fullUrl: #{getFullUrl}" if Zapiclient::Utils.instance.isVerbose?

      @updateData["status"] = { "id" => status }
      @updateData["comment"] = comment if !comment.nil?

      @xupdateData = {
          "issueId": '45699',
          "executionId": '0001517402203431-242ac112-0001',
          "status" => { "id" => status}
      }.to_json


      ## KPP-47   (Cycle: beta1, Version: Release CORE 6.2, Project: Kinetica Playground)
      puts __FILE__ + (__LINE__).to_s + " update => #{@updateData}" if Zapiclient::Utils.instance.isVerbose?
      @response = RestClient.put getFullUrl, @updateData.to_json, headers
      @rc = JSON.parse(@response)

      if Zapiclient::Utils.instance.isVerbose?
        puts __FILE__ + (__LINE__).to_s + "== [UpdateExecution Response] =="
        puts JSON.pretty_generate @rc
        puts '=' * 72
      end

      @rc
    end

    def execute(status, comment)
      _updateExecution(Zapiclient::Utils.instance.toStatusId(status), comment)
    end


  end


end

