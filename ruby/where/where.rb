class Array
  def where(args, chain = self)
    chain = where(args.drop(1), chain) if args.count > 1
    key, val = args.first[0], args.first[1]
    return chain.select { |i| i[key] =~ val } if val.is_a?(Regexp)
    chain.select { |i| i[key] ==  val }
  end
end