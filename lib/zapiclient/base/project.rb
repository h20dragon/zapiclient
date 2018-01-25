

require 'json'
require_relative 'release'

module Zapiclient

  class Project

    attr_accessor :response
    attr_accessor :project

    def initialize(p)
      @debug = false
      puts __FILE__ + (__LINE__).to_s + " Zapiclient::Project()" if @debug
      @project = p
      puts @project if @debug
    end


    def getId()
      @project[:info]['id']
    end

    def getName()
      @project[:info]['name']
    end

    def getReleases()
      @project[:fixVersions]
    end

    def getRelease(name)
      hit = @project[:fixVersions].find { |fixVersion| fixVersion['name'].to_s == name }

      puts __FILE__ + (__LINE__).to_s + " HIT => #{hit}" if @debug
      return Zapiclient::Release.new(hit, getId())
    end

    def _searchCycles(opts)
      puts __FILE__ + (__LINE__).to_s + " [client.searchCycles]" if @debug
      _c = Zapiclient::Commands::SearchCycles.new(opts)
      hit = _c.execute()
    end


    # TODO: is this dead code?
    def getCycle()
      cycle = _searchCycles( { :projectId => @project['id'], :versionId => '13153'})
    end



  end


end
