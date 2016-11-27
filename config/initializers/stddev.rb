class String
  def concord(pattern, width = 70, bmark = '\\emph{', emark = '}', tmark = '\\dots')
    matches = self.to_enum(:scan, pattern).map{ Regexp.last_match }
    return nil if matches.blank?

    l = self.length
    String.new.tap do |s|
      i = 0
      matches.each do |match_data|
        b = match_data.begin(0)
        e = match_data.end(0)
        s << self[i...b]
        s << bmark unless bmark.nil?
        s << self[b...e]
        s << emark unless emark.nil?
        i = e
      end
      s << self[i..l] if i != (l - 1)
    end# .truncate(width, :separator => /\s+/)
  end
end

module Enumerable
  alias :collocation :each_cons

  def freq
    self.each_with_object(Hash.new(0)) { |item,counts| counts[item] += 1 }.sort_by(&:last).reverse
  end

  def sum
    self.inject(0){|accum, i| accum + i }
  end

  def mean
    self.sum/self.length.to_f
  end

  def sample_variance
    m = self.mean
    sum = self.inject(0){|accum, i| accum +(i-m)**2 }
    sum/(self.length - 1).to_f
  end

  def standard_deviation
    return Math.sqrt(self.sample_variance)
  end
end
