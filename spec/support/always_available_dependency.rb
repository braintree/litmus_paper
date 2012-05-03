class AlwaysAvailableDependency
  def available?
    true
  end

  def to_s
    self.class.name
  end
end
