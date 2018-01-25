
require 'json'

module Zapiclient

  class Cycles

    attr_accessor :projectId
    attr_accessor :response

    def initialize(json, projectId)
      @response = json
      @projectId = projectId
      @debug = false
    end

    def getNames()
      @response.map { |cycle| cycle['name']}
    end


    def testSummary(cycleName=nil)
      puts ">>> Cycle Names for project #{@projectId}  : cycle #{cycleName} <<<"

      puts JSON.pretty_generate @response if cycleName.nil?

      i=0
      @response.each do |cycle|

        if cycleName.nil? || cycleName == cycle['name']
          puts JSON.pretty_generate cycle

          puts "#{i.to_s}. #{cycle['name']}"
          puts "\tdescription: #{cycle['description']}"
          puts "\tenvironment: #{cycle['environment']}"
          puts "\tfrom: #{cycle['startDate'].to_s} to: #{cycle['endDate'].to_s}"
          puts "\tExecution total: #{cycle['totalExecutions']}"
          puts"\t\to "
          puts "\tDefects        : #{cycle['totalDefects']}"
          puts "\taction         : #{cycle['action']}"

          if cycle['action']!='expand'
            # raise "SHOULD_EXPAND_ACTION"
            # ;
          end
          i+=1

          break if cycleName == cycle['name']
        end

      end
    end


    def _searchCycle(opts)
      puts __FILE__ + (__LINE__).to_s + " [client.searchCycles]" if @debug
      _c = Zapiclient::Commands::SearchCycle.new(@projectId.to_s, opts[:versionId].to_s, opts[:cycleId].to_s)
      cycle = _c.execute()   # Returns instanceof Cycle
    end

    def getCycle(name)
      hit = @response.find { |cycle| cycle['name']==name}
     _searchCycle(  {:versionId => hit['versionId'], :cycleId => hit['id'] })
    end


  end


end
