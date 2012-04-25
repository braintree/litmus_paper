class ConstantMetric
  def initialize(constant)
    @constant = constant
  end

  def current_health
    @constant
  end
end
