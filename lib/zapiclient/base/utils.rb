
require 'singleton'
require 'pp'
require 'optparse'

module Zapiclient

  class Utils
    include Singleton

    attr_accessor :options

    def initialize
      @options={}

      [:project, :release, :cycle, :release, :verbose].each do |k|
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

    def getCycle()
      @options[:cycle].to_s
    end

    def getTestCase()
      @options[:testcase].to_s
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

        opt.on('--cycle [Cycle]') { |o| @options[:cycle]=o }

        opt.on('--status:execution [pass, fail, unexecuted, wip') { |o| @options[:status][:execution]=o }

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

  end

end
