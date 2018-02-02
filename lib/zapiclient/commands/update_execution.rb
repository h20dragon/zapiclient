

require 'rest_client'
require 'atlassian/jwt'
require 'digest'
require 'json'
require_relative './command'

module Zapiclient::Commands


  class UpdateExecution < Command

    BASE_URL = '/public/rest/api/1.0/execution/{EXECUTION_ID}'
    attr_accessor :updateData

    def initialize( u )
      @updateData = {}
      tmpStr = BASE_URL.sub('{EXECUTION_ID}', u[:executionId].to_s)

      setUri(tmpStr)

      _status = { "id" =>  u[:status] }  # 1, 2, 3, 4

      if Zapiclient::Utils.instance.isVerbose?
        puts "[UpdateExecution.init]: #{u}"
      end

      @updateData = { "status" => _status,
                      "id" => u[:executionId],
                      "projectId" => u[:projectId].to_s,
                      "issueId" => u[:issueId].to_s,
                      "versionId" => u[:versionId],
                      "comment" => Zapiclient::Utils.instance.getComment()
                    }.to_json
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

    def execute()
      _updateExecution()
    end


  end


end

