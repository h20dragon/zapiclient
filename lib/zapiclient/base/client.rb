require 'pp'
require 'rest_client'
require 'atlassian/jwt'
require 'digest'
require 'json'

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

    def getIssue(parms)
      _c = Zapiclient::Commands::GetIssue.new()
     # _c.execute(parms[:project], parms[:cycleName], parms[:testcase])
     _c.execute(parms)
    end


    # Get test steps for a provided Testcase (Project/Release needed)
    def getAllTestSteps(parms)
      issue = getIssue(parms)
      puts __FILE__ + (__LINE__).to_s + " getIssue => #{issue}" if Zapiclient::Utils.instance.isVerbose?
      opt = { :projectId => issue['searchObjectList'][0]['execution']['projectId'].to_s,
                :issueId => issue['searchObjectList'][0]['execution']['issueId'].to_s
              }
      _c = Zapiclient::Commands::GetAllTestSteps.new(opt)
      testSteps = _c.execute()
      opt[:testSteps] = testSteps
      opt
    end

    # Find a specific test step for a specific TestCase (Project)
    def getTestStep(parms, step)

      if step.nil?
        puts "[getTestStep]: \"step\" is required."
        exit(1)
      end

      allSteps = getAllTestSteps(parms)

      if allSteps
        regEx = Regexp.new(step)
#        testStep = allSteps[:testSteps].find { |s| s['step'].match(/#{step}/)}
        testStep = allSteps[:testSteps].find { |s| s['step'].match(regEx)}
      end

      rc = parms
      rc[:testStep] = testStep

      return rc
    end



    def getCycleStepResults(parms)
      if !parms.has_key?(:cycleName)
        puts "[getCycleStepResults]: requires CycleName"
        exit(1);
      end
      issue = getIssue(parms)
      _c = Zapiclient::Commands::GetStepResults.new(issue['searchObjectList'][0]['execution']['id'].to_s, issue['searchObjectList'][0]['execution']['issueId'].to_s)
      _c.execute()
    end


    def updateCycleTestStepResult(parms, step, status, comment=nil)
      if !(parms.has_key?(:testcase) || parms.has_key?(:cycleName))
        puts "[updateCycleTestStepResult]: Missing testcase ID"
        exit(1)
      end

      # Get stepId, issueID based on TestCase step
      hit = getTestStep(parms, step)

      if Zapiclient::Utils.instance.isVerbose?
        puts __FILE__ + (__LINE__).to_s + " [getTestStep] "
        puts JSON.pretty_generate hit
      end

      if !(hit && hit.has_key?(:testStep) && hit[:testStep])
        puts "[updateCycleTestStepResult]: Test step, #{step}, not found"
        exit(1)
      end

      stepID = hit[:testStep]['id'].to_s
      issueID = hit[:testStep]['issueId'].to_s

      # Get stepResultId
      executionSteps = getCycleStepResults(parms)

      puts __FILE__ + (__LINE__).to_s + " [getCycleStepResults] #{stepID} => #{executionSteps.keys}" if Zapiclient::Utils.instance.isVerbose?

      step = executionSteps['stepResults'].find { |s| s['stepId']==stepID}

      executionId = step['executionId']

    #  cmd = Zapiclient::Commands::GetStepResultExecution.new(executionId, issueID)
    #  xx = cmd.execute()
      if Zapiclient::Utils.instance.isVerbose?
        puts __FILE__ + (__LINE__).to_s + " [EXECUTION ID: STEP]: #{executionId}"
        puts __FILE__ + (__LINE__).to_s + " STEP_RESULT_ID: #{step['id']}"
        puts  JSON.pretty_generate step
        puts __FILE__ + (__LINE__).to_s + "+++++++++++++++++++++++++++"
      end

      req = {:stepResultId => step['id'],
             :issueId => step['issueId'],
             :executionId => step['executionId']
            }
      _c = Zapiclient::Commands::UpdateExecutionStepResult.new( req )
      _c.execute(status, comment)
    end

    def updateTestStep(parms)
      testSteps = getAllTestSteps(parms)
      _c = Zapiclient::Commands::UpdateTestStep.new(testSteps)
      _c.execute
    end

    def update(parms)
      _project = parms[:project]
      _release = parms[:release]
      _cycle = parms[:cycle]
      _status = parms[:status][:execution]
      _testcase = parms[:testcase]

      hits = zqlSearch("project=\"#{_project}\" and fixVersion=\"#{_release}\" and cycleName=\"#{_cycle}\" and issue=\"#{_testcase}\"")

      issue = hits['searchObjectList'][0]

      rec = { :status => Zapiclient::Utils.instance.toStatusId(_status),  # "1",
              :executionId => issue['execution']['id'].to_s,   #"0001516461606832-242ac112-0001",
              :projectId => issue['execution']['projectId'].to_s,   # myProject.getId().to_s,
              :issueId => issue['execution']['issueId'].to_s,
              :versionId => issue['execution']['versionId'].to_s  # myRelease.getId().to_s
      }

      puts "[updateExecution]" if Zapiclient::Utils.instance.isVerbose?
      rc = updateExecution(rec)
      puts "Update Results => #{rc} to #{_status}" if Zapiclient::Utils.instance.isVerbose?
      return rc
    end



  end



end
