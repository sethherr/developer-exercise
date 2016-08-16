class Array
  def where(args)
    args.each do |key, val|
      next select! { |i| i[key] =~ val } if val.is_a?(Regexp)
      select! { |i| i[key] == val }
    end
    self
  end
end