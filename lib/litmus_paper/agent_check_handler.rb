module LitmusPaper
  class AgentCheckHandler
    def self.handle(service)
      @cache ||= LitmusPaper::Cache.new(
        LitmusPaper.cache_location,
        "litmus_cache",
        LitmusPaper.cache_ttl
      )
      output = []

      health = @cache.get(service)
      @cache.set(
        service,
        health = LitmusPaper.check_service(service)
      ) unless health

      if health.nil?
        output << "failed#NOT_FOUND"
      else
        case health.direction
        when :up, :health
          output << "ready" # administrative state
          output << "up" # operational state
        when :down
          output << "drain" # administrative state
        when :none
          if health.ok?
            output << "ready" # administrative state
            output << "up" # operational state
          else
            output << "down" # operational state
          end
        end
        output << "#{health.value.to_s}%"
      end
      output.join("\t")
    end
  end
end
