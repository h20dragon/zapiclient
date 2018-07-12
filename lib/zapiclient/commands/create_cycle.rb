
require 'json'
require_relative './command'

module Zapiclient::Commands

  class CreateCycle < Command

    BASE_URL = '/public/rest/api/1.0/cycle?expand=&clonedCycleId='

    attr_accessor :cycleInfo

    def initialize()
      super(BASE_URL)
      @cycleInfo = nil
      puts __FILE__ + (__LINE__).to_s + " [CreateCycle.init]" if Zapiclient::Utils.instance.isVerbose?
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
                                  @cycleInfo.to_json,
                                  headers)
      return JSON.parse(@response)
    end


    def execute(createInfo)
      @cycleInfo = createInfo

      @response = sendRequest()

      if Zapiclient::Utils.instance.isVerbose?
        puts __FILE__ + (__LINE__).to_s + "== [CreateCycle.execute] =="
        puts JSON.pretty_generate @response
        puts '=' * 72
      end

      @response
    end


    def getCycleId()
      @response['searchObjectList'][0]['execution']['cycleId']
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
