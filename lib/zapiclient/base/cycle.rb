



require 'json'

module Zapiclient

  class Cycle

    attr_accessor :projectId
    attr_accessor :cycle

    def initialize(json, projectId)
      @cycle = json
      @projectId = projectId
      @debug = false
    end

    def getName()
      @cycle['name']
    end

    def getId()
      @cycle['id']
    end

    def testSummary()
      puts ">>> Cycle Names for project #{@projectId}  : cycle #{getName()} <<<"

      puts JSON.pretty_generate cycle

      puts "name: #{@cycle['name']}"
      puts "\tdescription: #{@cycle['description']}"
      puts "\tenvironment: #{@cycle['environment']}"
      puts "\tfrom: #{@cycle['startDate'].to_s} to: #{@cycle['endDate'].to_s}"
      puts "\tExecution total: #{@cycle['totalExecutions']}"
      puts"\t\to "
      puts "\tDefects        : #{@cycle['totalDefects']}"
      puts "\taction         : #{@cycle['action']}"

      if @cycle['action']!='expand'
        raise "SHOULD_EXPAND_ACTION"
        # ;
      end


    end


    def _searchCycle(opts)
      puts __FILE__ + (__LINE__).to_s + " [client.searchCycles]" if @debug
      _c = Zapiclient::Commands::SearchCycle.new(@projectId.to_s, opts[:versionId].to_s, opts[:cycleId].to_s)
      cycles = _c.execute()   # Returns instanceof Cycles
    end

    def getCycle(name)
      hit = @response.find { |cycle| cycle['name']==name}

      _searchCycle(  {:versionId => hit['versionId'], :cycleId => hit['id'] })
    end


  end


end
