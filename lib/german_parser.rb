module GermanParser
  class Parser
    def initialize
      @crd, cwr = IO.pipe
      prd, @pwr = IO.pipe
      @pid = Process.spawn(Rails.root.join('bin/pattern-tagger.py').to_s, :out => cwr, :in => prd, :err => $stderr)
      prd.close
      cwr.close
    end

    def close
      @pwr.write("000\n") rescue Errno::EPIPE
      @pwr.close
      @crd.close
      Process.waitpid @pid
    end

    def parse(sent)
      @pwr.write(sent + "\n")
      @crd.readline.strip.split(' ').map do |x|
        e = x.split('/')
        {:word  => e[0],
         :pos   => e[1],
         :pos_v => e[1...-1].join('|'),
         :lemma => e[-1]
        }
      end
    end
  end
end
