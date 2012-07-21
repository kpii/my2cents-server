module Base62
  CHARS = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".split('')

  def self.encode(i)
    return '0' if i == 0
    s = ''
    while i > 0
      s << CHARS[i.modulo(62)]
      i /= 62
    end
    s.reverse!
    s
  end
  
  def self.decode(s)
    pos = 0
    s.split('').reverse.inject(0) do |sum, c|
      sum += CHARS.index(c) * 62**pos
      pos += 1
      sum
    end
  end
end
