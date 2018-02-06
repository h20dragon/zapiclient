require 'net/http'
require 'uri'
require 'json'
require 'mime/types'
require_relative './command'

module Zapiclient::Commands

  class AddAttachment < Command
    BOUNDARY = "AaB03x"
    BASE_URL = '/public/rest/api/1.0/attachment?issueId={ISSUE_ID}&versionId={VERSION_ID}&entityName={ENTITY_NAME}&cycleId={CYCLE_ID}&entityId={ENTITY_ID}&comment={COMMENT}&projectId={PROJECT_ID}'

    def initialize(rec)
      tmpStr = BASE_URL.sub('{PROJECT_ID}', rec[:projectId])
      tmpStr = tmpStr.sub('{ISSUE_ID}', rec[:issueId])
      tmpStr = tmpStr.sub('{VERSION_ID}', rec[:versionId])
      tmpStr = tmpStr.sub('{ENTITY_NAME}', rec[:entityName])
      tmpStr = tmpStr.sub('{CYCLE_ID}', rec[:cycleId])
      tmpStr = tmpStr.sub('{ENTITY_ID}', rec[:executionId])
      tmpStr = tmpStr.sub('{COMMENT}', rec[:comment])

      setUri(tmpStr)
      puts __FILE__ + (__LINE__).to_s + " [addAttachment.init]: #{tmpStr}" if Zapiclient::Utils.instance.isVerbose?
    end

    def sendRequest(file)
      myClaim = Atlassian::Jwt.build_claims(getAccessKey, getFullUrl, 'post', getBaseUrl())
      @jwt = 'JWT ' + JWT.encode(myClaim, getSecretKey)

      headers = {
          :content_type => "multipart/form-data; boundary=#{BOUNDARY}",
          :authorization => @jwt,
          :zapiaccesskey => getAccessKey()
      }

      post_body = []

      # Add the file Data
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data; name=\"user[][image]\"; filename=\"#{File.basename(file)}\"\r\n"
      post_body << "Content-Type: #{MIME::Types.type_for(file)}\r\n\r\n"
      post_body << File.read(file)

      # Add the JSON
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data; name=\"user[]\"\r\n\r\n"
      post_body << "\r\n\r\n--#{BOUNDARY}--\r\n"

      puts "fullURL: #{getFullUrl}" if Zapiclient::Utils.instance.isVerbose?

      @response = RestClient.post(getFullUrl,
                                  post_body.join,
                                  headers)
      return JSON.parse(@response)
    end


    def execute(f)
      @response = sendRequest(f)

      if Zapiclient::Utils.instance.isVerbose?
        puts __FILE__ + (__LINE__).to_s + "== [AddAttachment.execute] =="
        puts JSON.pretty_generate @response
        puts '=' * 72
      end

      @response
    end


  end

end
