module LitmusPaper
  class ForcedHealth
    attr_reader :summary

    def initialize(health, summary)
      @health = health
      @summary = summary
    end

    def value
      @health
    end

    def ok?
      @health > 0
    end
  end
end
