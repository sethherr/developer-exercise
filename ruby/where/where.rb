class Array
  def where(args, chain = self)
    chain = where(args.drop(1), chain) if args.count > 1
    key, val = args.first[0], args.first[1]
    chain.select { |i| val.is_a?(Regexp) ? i[key] =~ val : i[key] == val }
  end
end