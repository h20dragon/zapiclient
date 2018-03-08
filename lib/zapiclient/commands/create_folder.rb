
require 'json'
require_relative './command'

module Zapiclient::Commands

  class CreateFolder < Command

    BASE_URL = '/public/rest/api/1.0/folder'

    attr_accessor :status
    attr_accessor :executionList

    def initialize()
      super(BASE_URL)

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
          "name" => "PETER_TEST",
          "cycleId" => @cycleId,
          "versionId" => @versionId.to_i,
          "projectId" => @projectId.to_i }.to_json

      puts "REQ => #{@request}" if Zapiclient::Utils.instance.isVerbose?

      @response = RestClient.post(getFullUrl,
                                  @request,
                                  headers)
    end


    def execute(p, v, c, name)
      @projectId = p
      @versionId = v
      @cycleId = c
      @folderName = name

      if Zapiclient::Utils.instance.isVerbose?
        puts "projectId: #{@projectId}"
        puts "versionId: #{@versionId}"
        puts "cycleId  : #{@cycleId}"
        puts "folder   : #{@folderName}"
      end

      @response = sendRequest()
    end

  end

end
