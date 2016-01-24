module Translator
  class Google
    def initialize(src: :en, dst: :tr)
      @cmd = Rails.root.join('bin/gt').to_s + " #{src}:#{dst}"

      @crd, cwr = IO.pipe
      prd, @pwr = IO.pipe
      @pid = Process.spawn(@cmd, :out => cwr, :in => prd, :err => $stderr)
      prd.close
      cwr.close
    end

    def close
      @pwr.write("000\n")
      @pwr.close
      @crd.close
      Process.waitpid @pid
    end

    def translate(sentence)
      @pwr.write(sentence.strip + "\n")
      @crd.readline.strip
    end
  end
end
