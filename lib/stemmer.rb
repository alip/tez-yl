module Stemmer
  class Porter
    def initialize
      @crd, cwr = IO.pipe
      prd, @pwr = IO.pipe
      @pid = Process.spawn(Rails.root.join('bin/stem-porter.py').to_s, :out => cwr, :in => prd, :err => $stderr)
      prd.close
      cwr.close
    end

    def close
      @pwr.write("000\n")
      @pwr.close
      @crd.close
      Process.waitpid @pid
    end

    def stem(word)
      @pwr.write(word + "\n")
      @crd.readline.strip
    end
  end
end
