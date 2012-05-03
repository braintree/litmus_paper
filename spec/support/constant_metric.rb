class ConstantMetric
  def initialize(constant)
    @constant = constant
  end

  def current_health
    @constant
  end

  def to_s
    "#{self.class.name}(#{@constant})"
  end
end
