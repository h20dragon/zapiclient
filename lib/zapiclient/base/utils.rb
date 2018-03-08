
require 'singleton'
require 'pp'
require 'optparse'

module Zapiclient

  class Utils
    include Singleton

    attr_accessor :options
    attr_accessor :cmd

    def initialize
      @options={}

      @cmd = nil

      [:add_attachment, :add_tests_to_cycle, :build_name, :command, :comment, :create_cycle, :cycle,
       :description, :environment, :file, :folder, :folders,
       :project, :release, :report, :reset, :search, :step, :testcase_list, :update, :update_teststep_status,
       :verbose].each do |k|
        @options[k]=nil
      end

      @options[:status]={:execution => nil}
    end

    def getBuild()
      @options[:build_name]
    end

    def getProject()
      @options[:project].to_s
    end

    def getZqlString()
      @options[:search].to_s
    end

    def getEnvironment()
      @options[:environment]
    end

    def getRelease()
      @options[:release]
    end

    def getComment()
      @options[:comment]
    end
    def getCycle()
      @options[:cycle].to_s
    end

    def getTestCase()
      @options[:testcase].to_s
    end

    def isVerbose?
      @options[:verbose]
    end

    def getDescription()
      @options[:description]
    end

    def getFile()
      @options[:file]
    end

    def getStep()
      @options[:step]
    end

    def getStatus()
      @options[:status].to_s
    end

    def getTestCases()
      @options[:testcase_list]
    end

    def getExecutionStatus()
      @options[:status][:execution].to_s
    end

    def parseCommandLine(args=nil)

      opt_parser = OptionParser.new do |opt|

        opt.on("-v", '--verbose', "Run verbosely") { |o| @options[:verbose]=o }
        opt.on('--file [File]') { |o| @options[:file]=o }

        opt.on('--folders', "Get Folders") { |o| @options[:folders]=o }

        opt.on('--project [ProjectName]') { |o| @options[:project]=o }
        opt.on('--release [ReleaseName]') { |o| @options[:release]=o }
        opt.on('--cycle [Cycle]') { |o| @options[:cycle]=o }
        opt.on('--testcase [TestcaseID]') { |o| @options[:testcase]=o }
        opt.on('--testcases [Testcase List]') { |o| @options[:testcase_list]=o }

        opt.on('--search [ZqlString]') { |o| @options[:search]=o }

        opt.on('--build [Build]') { |o| @options[:build_name]=o }
        opt.on('--comment [Comment]') { |o| @options[:comment]=o }
        opt.on('--description [Description]') { |o| @options[:description]=o }
        opt.on('--environment [Environment]') { |o| @options[:environment]=o }
        opt.on('--step [Step]') { |o| @options[:step]=o }

        opt.on('--status Status',  [:blocked, :pass, :fail, :unexecuted, :wip], "Specify execution status") { |o| @options[:status][:execution]=o }
        opt.on('--status:execution Status',  [:blocked, :pass, :fail, :unexecuted, :wip], "Specify execution status") { |o| @options[:status][:execution]=o }


        # Commands
        #
        opt.on('--add:tests', "Add tests to Cycle") { |o| @options[:add_tests_to_cycle] = o }
        opt.on('--attach', "Add attachment") { |o| @options[:add_attachment] = o }
        opt.on('--create:cycle CycleName', "[String]") do |o|
          @options[:cycle] = o
          @options[:create_cycle] = true
        end
        opt.on('--folder [Folder]') { |o| @options[:folder]=o }
        opt.on('--report:cycle', "Report Cycle") { |o| @options[:report] = o }
        opt.on('--reset:cycle', "Reset Cycle") { |o| @options[:reset] = o }
        opt.on('--update', "Update execution") { |o| @options[:update] = o }
        opt.on('--update:teststep:status', "Update test step execution") { |o| @options[:update_teststep_status] = o }
      end

      if !args.nil?
        opt_parser.parse!(args)
      else
        opt_parser.parse!
      end

      if @options[:update]
        if !@options[:release]
          puts "Update requires a specified release."
          exit(1)
        end

        if !@options[:project]
          puts "Update requires a specified project"
          exit(1)
        end

        if !@options[:testcase]
          puts "Update requires a specified testcase ID"
          exit(1)
        end

        if !@options[:status]
          puts "Update requires a specified status (pass|fail|unexpected|block|wip)"
          exit(1)
        end

        @cmd = 'update'

      elsif @options[:search]
        @cmd = 'search'
      elsif @options[:report]
        @cmd = 'report'
      elsif @options[:folders]
        @cmd = 'folders'
      elsif @options[:folder]
        @cmd = 'create_folder'
      elsif @options[:update_teststep_status]
        @cmd = 'update_teststep_status'
      elsif @options[:add_attachment]
        @cmd = 'add_attachment'
      elsif @options[:create_cycle]
        @cmd = 'create_cycle'
      elsif @options[:add_tests_to_cycle]
        @cmd = 'add_tests_to_cycle'
      elsif @options[:reset]
        @cmd = 'reset_cycle'
      end

      if !@cmd
        puts "Command was not specified."
        exit(1)
      end

      puts "[parseCommandLine]: #{@options}" if @options[:verbose]
      @options
    end

    def isAddAttachment?
      @options[:add_attachment]
    end

    def isAddTestsToCycle?
      @options[:add_tests_to_cycle]
    end

    def isCreateCycle?
      @options[:create_cycle]
    end

    def isFolder?
      @options[:folder]
    end

    def isFolders?
      @options[:folders]
    end

    def isReport?
      @options[:report]
    end

    def isResetCycle?
      @options[:reset]
    end

    def isSearch?
      @options[:search]
    end

    def isUpdate?
      @options[:update]
    end

    def isUpdateTestStepStatus?
      @options[:update_teststep_status]
    end

    def isValidStatus(s)
      !s.to_s.downcase.strip.match(/(pass|fail|wip|unexecuted|wip|block)/).nil?
    end

    def toStatusId(s)
      id = 0
      _status = nil

      if s.is_a?(Hash) && s.has_key?(:execution)
        _status = s[:execution].to_s.downcase.strip
      else
        _status = s.to_s.downcase.strip
      end

      if _status.match(/pass/i)
        id = '1'
      elsif _status.match(/fail/i)
        id = '2'
      elsif _status.match(/wip/i)
        id = '3'
      elsif _status.match(/block/i)
        id = '4'
      elsif _status.match(/unexecuted/i)
        id = '-1'
      else
        puts "INVALID_STATUS: #{s.to_s}"
        exit(1)
      end

      return id
    end

  end

end
