
require 'json'
require_relative './command'

module Zapiclient::Commands

  class ZqlSearch < Command

    BASE_URL = '/public/rest/api/1.0/zql/search?'

    attr_accessor :zqlQuery

    def initialize()
      super(BASE_URL)
      @debug = false

      @zqlQuery = ""
      puts __FILE__ + (__LINE__).to_s + " [ZqlSearch.init]" if @debug
    end

    # 'project="ABC" and versionName="Release CORE 6.2" and cycleName="XYZ"'
    def searchUsing(filter)
      @zqlQuery = filter
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
                                  { 'zqlQuery' => @zqlQuery }.to_json,
                                  headers)
      return JSON.parse(@response)
    end


    def execute()
      @response = sendRequest()

      if @debug
        puts __FILE__ + (__LINE__).to_s + "== [ZqlSearch.execute] =="
        puts JSON.pretty_generate @response
        puts '=' * 72
      end

      @response
    end


    def getCycleId()
      @response['searchObjectList']['execution']['cycleId']
    end

    def getProject()
      hit = {}

      if @response.has_key?('searchObjectList') && @response['searchObjectList'].length == 0
        return {}
      else
        hit[:project] = { :id   => @response['searchObjectList'][0]['execution']['projectId'].to_s,
                         :name => @response['searchObjectList'][0]['projectName'].to_s
                        }
        hit[:cycle] = { :id => @response['searchObjectList'][0]['execution']['cycleId'],
                        :name => @response['searchObjectList'][0]['execution']['cycleName'] }
        hit[:version] = getVersion()
      end

      return hit
    end

    def getVersion()
      rc = { :id => @response['searchObjectList'][0]['execution']['versionId'],
              :name => @response['searchObjectList'][0]['versionName'].to_s
            }
      rc
    end

  end

end
