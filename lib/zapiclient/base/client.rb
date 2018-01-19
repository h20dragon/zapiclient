require 'pp'
require 'rest_client'
require 'atlassian/jwt'
require 'digest'

module Zapiclient

  class Client


    attr_accessor :claim

    # TODO: Leverage command pattern.
    EXECUTION_CMD="/jira/rest/zapi/latest/execution"


    ZAPI_LIST = {
        :cycle => "/jira/rest/zapi/latest/cycle"
    }

    attr_accessor :debug
    attr_accessor :user

    def initialize(*p)

      @claim = {}

      if p.size == 0
        puts __FILE__ + (__LINE__).to_s + " Use System Defaults"
        claim[:user] = ENV['ZAPI_USER']
        claim[:baseUrl] = 'https://prod-api.zephyr4jiracloud.com/connect'
        claim[:secretKey] = ENV['ZAPI_SECRET_KEY']
        claim[:accessKey] = ENV['ZAPI_ACCESS_KEY']
      end



      puts __FILE__ + (__LINE__).to_s + " claim => #{claim}"

      if false
        if claim.empty?
          raise "INSUFFCIENT_ZAPI_CREDS"
        end


        hash_lib = Digest::SHA256.new

        uri = 'https://prod-api.zephyr4jiracloud.com/connect/public/rest/api/1.0/serverinfo'
        #uri = 'https://prod-api.zephyr4jiracloud.com/connect/public/rest/api/1.0/cycles/search?projectId=13301&versionId=-1';


        myClaim = Atlassian::Jwt.build_claims(claim[:accessKey], uri, 'get', claim[:baseUrl])
        jwt = 'JWT ' + JWT.encode(myClaim, claim[:secretKey])

        puts __FILE__ + (__LINE__).to_s + " JWT => " + jwt


        headers = {
            :content_type => 'application/json',
            :authorization => jwt,
            :zapiaccesskey => claim[:accessKey]
        }

        response = RestClient.get 'https://prod-api.zephyr4jiracloud.com/connect/public/rest/api/1.0/serverinfo', headers
        puts response
      end

    end


    def searchCycles(opts)
      puts __FILE__ + (__LINE__).to_s + " [client.searchCycles]"
      _c = Zapiclient::Commands::SearchCycles.new(opts)
      _c.execute()
    end

    def serverinfo()
      puts __FILE__ + (__LINE__).to_s + " [client.serverInfo]"
      _c = Zapiclient::Commands::ServerInfo.new()
      _c.execute();
    end

  end



end
