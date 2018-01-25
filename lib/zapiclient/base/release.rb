

require 'json'

module Zapiclient

  class Release

    attr_accessor :projectId
    attr_accessor :releases
    attr_accessor :hit

    def initialize(r, projectId)
      @release = r
      @projectId = projectId
      @hit = nil
      @debug = false
    end

    def getId()
      @release['id'].to_s
    end

    def dump()
      puts __FILE__ + (__LINE__).to_s + " [Release.dump()]" if @debug
      puts @release
    end


    # Returns instanceOf Cycles
    def _searchCycles(opts)
      puts __FILE__ + (__LINE__).to_s + " [Release._searchCycles]" if @debug
      _c = Zapiclient::Commands::SearchCycles.new(opts)
      @hit = _c.execute()
    end

    def dump()
      puts __FILE__ + (__LINE__).to_s + " Release.dump()"
      puts @release
    end

    # Returns instanceOf Cycles
    def getCycles()
      _searchCycles({:projectId => @projectId.to_s, :versionId => @release['id'].to_s})
    end

  end




end
