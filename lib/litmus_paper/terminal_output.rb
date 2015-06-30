# encoding: UTF-8
module LitmusPaper
  class TerminalOutput
    def self.service_status
      max_service_length = (LitmusPaper.services.keys << "Service").max { |a, b| a.length <=> b.length }.length

      output = "Litmus Paper #{LitmusPaper::VERSION}\n"
      output += sprintf(" %s │ %s │ %s │ %s\n", "Service".ljust(max_service_length), "Reported", "Measured", "Forced")
      output += sprintf(" %s │ %s │ %s │ %s\n", "Name".ljust(max_service_length), "Health".ljust(8), "Health".ljust(8), "Down".ljust(6))
      output += "─" * (max_service_length + 2) + "┴" + "─" * 10 + "┴" + "─" * 10 + "┴" + "─" * 8 + "\n"

      LitmusPaper.services.each do |service_name, service|
        health = service.current_health
        measured_health = health.measured_health.to_s.rjust(3)
        reported_health = health.value.to_s.rjust(3)
        service_forced = if health.forced?
          "Yes: #{health.forced_reason}"
        else
          "No"
        end
        output += sprintf("* %-#{max_service_length}s   %s   %s   %s\n",
                          service_name,
                          reported_health.center(8).colorize(_health_color(health.value)),
                          measured_health.center(8),
                          service_forced,
                         )
      end

      return output
    end

    def self._health_color(health)
      if health == 0
        return :red
      elsif health < 80
        return :yellow
      else
        return :green
      end
    end

  end
end