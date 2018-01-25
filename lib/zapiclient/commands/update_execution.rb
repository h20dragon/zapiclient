

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

      @updateData = { "status" => _status,
                      "id" => u[:executionId],
                      "projectId" => u[:projectId].to_s,
                      "issueId" => u[:issueId].to_s,
                      "versionId" => u[:versionId]
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

      @response = RestClient.put getFullUrl,
                                @updateData, headers
      return JSON.parse(@response)
    end

    def execute()
      _updateExecution()
    end


  end


end

