class StubFacter
  def initialize(values)
    @values = values
  end

  def value(key)
    @values[key]
  end
end
