class NeverAvailableDependency
  def available?
    false
  end

  def to_s
    self.class.name
  end
end
