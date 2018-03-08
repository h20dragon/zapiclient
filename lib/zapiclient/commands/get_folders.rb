

require 'json'
require_relative './command'

module Zapiclient::Commands

  class GetFolders < Command

    BASE_URL = '/public/rest/api/1.0/folders?versionId={VERSION_ID}&cycleId={CYCLE_ID}&projectId={PROJECT_ID}'

    def initialize(opts)
      @debug = Zapiclient::Utils.instance.isVerbose?
      @projectId = opts[:projectId]
      tmpStr = BASE_URL.sub('{PROJECT_ID}', opts[:projectId])
      tmpStr = tmpStr.sub('{VERSION_ID}', opts[:versionId])
      tmpStr = tmpStr.sub('{CYCLE_ID}', opts[:cycleId])
      setUri(tmpStr)
    end


    def sendRequest()
      @jwt = jwt()
      headers = {
          :content_type => 'text/plain',
          :authorization => @jwt,
          :zapiaccesskey => getAccessKey()
      }
      @response = RestClient.get(getBaseUrl + @uri, headers)
      return JSON.parse(@response)
    end

    def execute()
      @response = sendRequest()

      if Zapiclient::Utils.instance.isVerbose?
        puts __FILE__ + (__LINE__).to_s + "== [GetFolders Response] =="
        puts JSON.pretty_generate @response
      end

      @response
    end

  end

end