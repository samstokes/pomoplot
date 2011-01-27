module Enumerable
  def each_pair
    rest = self
    while rest.any?
      yield(*rest.take(2))
      rest = rest.drop(2)
    end
  end

  def paired
    Enumerator.new(self, :each_pair)
  end
end
