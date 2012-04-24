class StubHardware

  attr_reader :processor_count, :memory_total, :memory_free, :load

  def initialize(overrides)
    @processor_count = overrides.fetch(:processor_count, 4)
    @memory_total = overrides.fetch(:memory_total, 4 * IPVSLitmus::Hardware::MULTIPLIER['GB'])
    @memory_free = overrides.fetch(:memory_free, 1 * IPVSLitmus::Hardware::MULTIPLIER['GB'])
    @load = overrides.fetch(:load, 2.50)
  end
end
