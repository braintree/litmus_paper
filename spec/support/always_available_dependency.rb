class AlwaysAvailableDependency < LitmusPaper::Dependency::Base
  def _available?
    true
  end

  def to_s
    self.class.name
  end
end
