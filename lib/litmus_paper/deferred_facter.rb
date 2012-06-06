module LitmusPaper
  class DeferredFacter
    def self.value(key)
      fiber = Fiber.current

      EM.defer(
        proc { Facter.value(key) },
        proc { |value| fiber.resume(value) }
      )

      return Fiber.yield
    end
  end
end
