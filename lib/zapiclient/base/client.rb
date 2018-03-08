require 'pp'
require 'rest_client'
require 'atlassian/jwt'
require 'digest'
require 'json'

require_relative '../base/project'

module Zapiclient

  class Client
    attr_accessor :claim

    EXPECTED_KEYS = { :user => 'ZAPI_USER',
                      :accessKey => 'ZAPI_ACCESS_KEY',
                      :secretKey => 'ZAPI_SECRET_KEY' }
    attr_accessor :debug
    attr_accessor :user
    attr_accessor :projects

    def initialize(*p)
      @claim = {}
      @debug = Zapiclient::Utils.instance.isVerbose?

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

    def _findRelease(parms)
      _project = parms[:project]
      _release = parms[:release]

      zqlSearch("project=\"#{_project}\" and fixVersion=\"#{_release}\"")
    end

    def _findCycle(parms)
      _project = parms[:project]
      _release = parms[:release]
      _cycle = parms[:cycle].to_s

      zqlSearch("project=\"#{_project}\" and fixVersion=\"#{_release}\" and cycleName = \"#{_cycle}\"")
    end

    def getCycles(opts)
      hit = _findRelease(opts)

      opts = {
          :projectId => hit['searchObjectList'][0]['execution']['projectId'].to_s,
          :versionId => hit['searchObjectList'][0]['execution']['versionId'].to_s,
          :expand => true
      }

      _c = Zapiclient::Commands::GetCycles.new(opts)
      rc = _c.execute()

      if Zapiclient::Utils.instance.isVerbose?
        puts "[getCycles]: #{opts}"
        puts JSON.pretty_generate rc
      end

      rc
    end

    def findCycle(opt)
      project = opt[:project]
      release = opt[:release]
      cycleName = opt[:cycle]
      cycleList = getCycles( { :project => project, :release => release })
      hit = cycleList.find { |c| c['name']==cycleName}

      if hit
        if  Zapiclient::Utils.instance.isVerbose?
          puts "Cycle #{cycleName} =>"
          puts JSON.pretty_generate hit
        end
      else
        puts "Cycle \"#{cycleName}\" was not found"
        exit(1)
      end

      hit
    end

    def _findTestCasePerCycle(parms)
      _project = parms[:project]
      _release = parms[:release]
      _cycle = parms[:cycle]
      _testcase = parms[:testcase]

      zqlSearch("project=\"#{_project}\" and fixVersion=\"#{_release}\" and cycleName=\"#{_cycle}\" and issue=\"#{_testcase}\"")
    end

    def addAttachment(parms)
      _project = parms[:project]
      _release = parms[:release]
      _cycle = parms[:cycle]
      _status = parms[:status]
      _testcase = parms[:testcase]

      hits = _findTestCasePerCycle(parms)

      issue = hits['searchObjectList'][0]

      if Zapiclient::Utils.instance.isVerbose?
        puts "[addAttachment]: "
        puts JSON.pretty_generate issue
      end

      rec = { # :status => Zapiclient::Utils.instance.toStatusId(_status),  # "1",
              :executionId => issue['execution']['id'].to_s,   #"0001516461606832-242ac112-0001",
              :projectId => issue['execution']['projectId'].to_s,   # myProject.getId().to_s,
              :issueId => issue['execution']['issueId'].to_s,
              :versionId => issue['execution']['versionId'].to_s,
              :cycleId => issue['execution']['cycleId'].to_s,
              :entityName => 'execution',
              :comment => parms['comment'] || Time.now.to_s
      }
      if Zapiclient::Utils.instance.isVerbose?
        puts "[addAttachment.execute with]: "
        puts JSON.pretty_generate rec
      end

      if Zapiclient::Utils.instance.getStatus() && Zapiclient::Utils.instance.isVerbose?
        puts __FILE__ + (__LINE__).to_s + " => #{Zapiclient::Utils.instance.getStatus()}"
      end

      _c = Zapiclient::Commands::AddAttachment.new(rec)
      rc = _c.execute(parms[:file].to_s)
      puts "AddAttachment Results => #{rc}" if Zapiclient::Utils.instance.isVerbose?
      return rc
    end


    def createCycle(opts)
      puts __FILE__ + (__LINE__).to_s + " [createCycle]: #{opts}" if Zapiclient::Utils.instance.isVerbose?

      releaseInfo = _findRelease(opts)

      puts JSON.pretty_generate releaseInfo if Zapiclient::Utils.instance.isVerbose?

      projectId = releaseInfo['searchObjectList'][0]['execution']['projectId']
      versionId = releaseInfo['searchObjectList'][0]['execution']['versionId']

      puts JSON.pretty_generate releaseInfo if Zapiclient::Utils.instance.isVerbose?

      _c = Zapiclient::Commands::CreateCycle.new()

      createInfo = {
          "name": opts[:cycleName],
          "build": Zapiclient::Utils.instance.getBuild().to_s,
          "environment": Zapiclient::Utils.instance.getEnvironment().to_s,
          "description": Zapiclient::Utils.instance.getDescription().to_s,
          #       "startDate":"1485278607",
          #       "endDate":"1485302400",
          "projectId":projectId,
          "versionId":versionId}

      puts "[createInfo] => #{createInfo}" if Zapiclient::Utils.instance.isVerbose?

      _c.execute(createInfo)
    end

    def addTestToCycle()
      parms = {
        :project => Zapiclient::Utils.instance.getProject,
        :release => Zapiclient::Utils.instance.getRelease,
        :cycle => Zapiclient::Utils.instance.getCycle
      }
      releaseInfo = _findRelease(parms)
      cycleInfo = findCycle(parms)


      if Zapiclient::Utils.instance.isVerbose?
        puts "Release Info => "
        puts JSON.pretty_generate releaseInfo
        puts '_' * 72
        puts "[addTestsToCycle] cycleInfo => "
        puts JSON.pretty_generate cycleInfo
        puts '_' * 72
      end

      testcaseList = Zapiclient::Utils.instance.getTestCases()

      if Zapiclient::Utils.instance.getFile
        f = File.new(Zapiclient::Utils.instance.getFile())
        testcaseList = ""
        f.each_line { |line| testcaseList+="#{line.strip}, "}
        testcaseList.gsub!(/\s,\s*$/, '')
      end


      if cycleInfo
        _c = Zapiclient::Commands::AddTestCycle.new({
                :projectId => releaseInfo['searchObjectList'][0]['execution']['projectId'],
                :versionId => releaseInfo['searchObjectList'][0]['execution']['versionId'],
                :cycleId => cycleInfo['id']
                                                    })
        _c.execute(testcaseList)
      end

    end

    def getCycleExecutions(parms)
      cycleInfo = _findCycle(parms)

      puts "[cycleInfo]:"
      puts JSON.pretty_generate cycleInfo

      i=0
      cycleInfo['searchObjectList'].each do |c|
        puts __FILE__ + (__LINE__).to_s + "#{i.to_s}. issuekey: #{c['issueKey']}  :  #{c['execution']['status']['name']}"
        i+=1
      end

     # projectId = cycleInfo['searchObjectList'][0]['execution']['projectId'].to_s
     # versionId = cycleInfo['searchObjectList'][0]['execution']['versionId'].to_s
     # cycleId = cycleInfo['searchObjectList'][0]['execution']['cycleId'].to_s
     # executionId = cycleInfo['searchObjectList'][0]['execution']['id'].to_s

   #   _c = Zapiclient::Commands::GetExecutions.new({:executionId => executionId})
   #   _c.execute()
     #
     cycleInfo
    end

    def reset(parms)
      cycleInfo = _findCycle(parms)

      executionIDs = cycleInfo['searchObjectList'].map { |c| c['execution']['id'] }

      _c = Zapiclient::Commands::UpdateBulkExecutions.new()
      _c.execute(executionIDs)
    end

    def createTestFolder(parms)
      cycleInfo = _findCycle(parms)
      projectId = cycleInfo['searchObjectList'][0]['execution']['projectId'].to_s
      versionId = cycleInfo['searchObjectList'][0]['execution']['versionId'].to_s
      cycleId = cycleInfo['searchObjectList'][0]['execution']['cycleId'].to_s

      _c = Zapiclient::Commands::CreateFolder.new()
      _c.execute(projectId, versionId, cycleId, "FOOx")
    end

    def getFolders(parms)
      cycleInfo = _findCycle(parms)
      opts = {
         :projectId => cycleInfo['searchObjectList'][0]['execution']['projectId'].to_s,
         :versionId => cycleInfo['searchObjectList'][0]['execution']['versionId'].to_s,
         :cycleId => cycleInfo['searchObjectList'][0]['execution']['cycleId'].to_s
      }

      _c = Zapiclient::Commands::GetFolders.new(opts)
      _c.execute

    end

    def searchCycle(parms)
      cycleInfo = _findCycle(parms)

      puts "[cycleInfo]:"
      puts JSON.pretty_generate cycleInfo

      projectId = cycleInfo['searchObjectList'][0]['execution']['projectId'].to_s
      versionId = cycleInfo['searchObjectList'][0]['execution']['versionId'].to_s
      cycleId = cycleInfo['searchObjectList'][0]['execution']['cycleId'].to_s
      executionIUd = cycleInfo['searchObjectList'][0]['execution']['id'].to_s

      _c = Zapiclient::Commands::SearchCycle.new(projectId, versionId, cycleId)
      _c.execute()
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
      puts __FILE__ + (__LINE__).to_s + " [client.zqlSearch]: #{searchFor}" if Zapiclient::Utils.instance.isVerbose?
      _c = Zapiclient::Commands::ZqlSearch.new()
      _c.searchUsing(searchFor)
      hit = _c.execute()
      if Zapiclient::Utils.instance.isVerbose?
        puts __FILE__ + (__LINE__).to_s + " Project => #{_c.getProject()}"
        puts __FILE__ + (__LINE__).to_s + " hit => #{hit}"
      end

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
