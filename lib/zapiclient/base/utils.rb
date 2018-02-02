
require 'singleton'
require 'pp'
require 'optparse'

module Zapiclient

  class Utils
    include Singleton

    attr_accessor :options

    def initialize
      @options={}

      [:command, :comment, :cycle, :project, :release, :step, :update, :update_teststep_status, :verbose].each do |k|
        @options[k]=nil
      end

      @options[:status]={:execution => nil}
    end


    def getProject()
      @options[:project].to_s
    end

    def getRelease()
      @options[:release].to_s
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

    def getStep()
      @options[:step]
    end

    def getStatus()
      @options[:status].to_s
    end

    def getExecutionStatus()
      @options[:status][:execution].to_s
    end

    def parseCommandLine(args=nil)

      opt_parser = OptionParser.new do |opt|

        opt.on("-v", '--verbose', "Run verbosely") { |o| @options[:verbose]=o }

        opt.on('--project [ProjectName]') { |o| @options[:project]=o }

        opt.on('--release [ReleaseName]') { |o| @options[:release]=o }
        opt.on('--comment [Comment]') { |o| @options[:comment]=o }
        opt.on('--cycle [Cycle]') { |o| @options[:cycle]=o }

        opt.on('--step [Step]') { |o| @options[:step]=o }

        opt.on('--status:execution [pass, fail, unexecuted, wip') { |o| @options[:status][:execution]=o }

        opt.on('--update', "Update execution") { |o| @options[:update] = o }
        opt.on('--update:teststep:status', "Update test step execution") { |o| @options[:update_teststep_status] = o }
        opt.on('--testcase [TestcaseID]') { |o| @options[:testcase]=o }

      end


      if !args.nil?
        opt_parser.parse!(args)
      else
        opt_parser.parse!
      end


      puts "[parseCommandLine]: #{@options}" if @options[:verbose]
      @options
    end

    def isUpdate?
      @options[:update]
    end

    def isUpdateTestStepStatus?
      @options[:update_teststep_status]
    end

    def toStatusId(s)
      id = 0
      _status = s.downcase.strip
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
