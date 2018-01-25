require 'pp'
require 'rest_client'
require 'atlassian/jwt'
require 'digest'

require_relative '../base/project'

module Zapiclient

  class Client


    attr_accessor :claim

    # TODO: Leverage command pattern.
    EXECUTION_CMD="/jira/rest/zapi/latest/execution"


    ZAPI_LIST = {
        :cycle => "/jira/rest/zapi/latest/cycle"
    }

    EXPECTED_KEYS = { :user => 'ZAPI_USER', :accessKey => 'ZAPI_ACCESS_KEY', :secretKey => 'ZAPI_SECRET_KEY' }

    attr_accessor :debug
    attr_accessor :user
    attr_accessor :projects


    def initialize(*p)

      @claim = {}
      @debug = false

      if p.size == 0
        puts __FILE__ + (__LINE__).to_s + " Use System Defaults" if @debug

        claim[:baseUrl] = 'https://prod-api.zephyr4jiracloud.com/connect'

        EXPECTED_KEYS.each_pair do |k, v|
          if ENV.has_key?(v)
            @claim[k] = ENV[v]
          else
            raise "MISSING_ENV_#{v}"
          end
        end
      end

      @projects = zqlValues()

      puts __FILE__ + (__LINE__).to_s + " claim => #{claim}" if @debug
    end



    def searchCycles(opts)
      puts __FILE__ + (__LINE__).to_s + " [client.searchCycles]" if @debug
      _c = Zapiclient::Commands::SearchCycles.new(opts)
      hit = _c.execute()
    end

    def serverinfo()
      puts __FILE__ + (__LINE__).to_s + " [client.serverInfo]" if @debug
      _c = Zapiclient::Commands::ServerInfo.new()
      _c.execute();
    end



    def updateExecution(record)
      puts __FILE__ + (__LINE__).to_s + " [client.updateExecution]" if @debug
      _c = Zapiclient::Commands::UpdateExecution.new(record)
      _c.execute()
    end

    def zql()
      puts __FILE__ + (__LINE__).to_s + " [client.zql]" if @debug
      _c = Zapiclient::Commands::Zql.new()
      _c.execute();
    end

    def zqlSearch(searchFor)
      puts __FILE__ + (__LINE__).to_s + " [client.zqlSearch]: #{searchFor}" if @debug
      _c = Zapiclient::Commands::ZqlSearch.new()
      _c.searchUsing(searchFor)
      hit = _c.execute()


      puts __FILE__ + (__LINE__).to_s + " Project => #{_c.getProject()}" if @debug
      hit
    end

    # {"id"=>13308, "key"=>"KPP", "name"=>"YOUR PROJECT NAME"}
    def getProject(s)
      if @projects
        return Project.new(@projects.getProject(s))
      end

      nil
    end

    def zqlValues()
      puts __FILE__ + (__LINE__).to_s + " [client.zql]" if @debug
      _c = Zapiclient::Commands::ZqlValues.new()
      _c.execute();
      return _c
    end


    def update(parms)

      _project = parms[:project]
      _release = parms[:release]
      _cycle = parms[:cycle]
      _status = parms[:status][:execution]
      _testcase = parms[:testcase]

      hits = zqlSearch("project=\"#{_project}\" and fixVersion=\"#{_release}\" and cycleName=\"#{_cycle}\" and issue=\"#{_testcase}\"")

      issue = hits['searchObjectList'][0]

      if _status.match(/pass/i)
        _status = '1'
      elsif _status.match(/fail/i)
        _status = '2'
      elsif _status.match(/wip/i)
        _status = '3'
      elsif _status.match(/block/i)
        _status = '4'
      elsif _status.match(/unexecuted/i)
        _status = '0'
      else
        exit 1
      end

      rec = { :status => _status,  # "1",
              :executionId => issue['execution']['id'].to_s,   #"0001516461606832-242ac112-0001",
              :projectId => issue['execution']['projectId'].to_s,   # myProject.getId().to_s,
              :issueId => issue['execution']['issueId'].to_s,
              :versionId => issue['execution']['versionId'].to_s  # myRelease.getId().to_s
      }

      puts "[updateExecution]" if @debug
      rc = updateExecution(rec)
      puts "Update Results => #{rc} to #{_status}" if @debug
      return rc
    end



  end



end
