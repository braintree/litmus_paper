class NeverAvailableDependency < LitmusPaper::Dependency::Base
  def _available?
    false
  end

  def to_s
    self.class.name
  end
end
