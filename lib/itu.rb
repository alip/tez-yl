require 'httparty'

module Itu
  class Nlp
    include HTTParty
    base_uri 'http://tools.nlp.itu.local'

    BD_TAG = '<DOC> <DOC>+BDTag'.freeze
    ED_TAG = '</DOC> </DOC>+EDTag'.freeze
    BS_TAG = '<S> <S>+BSTag'.freeze
    ES_TAG = '</S> </S>+ESTag'.freeze
    TAGS   = Set.new([BD_TAG, ED_TAG, BS_TAG, ES_TAG]).freeze

    def self.api_key
      return @key unless @key.nil?
      fail 'ITU_API_KEY not in environment' unless ENV.key?('ITU_API_KEY')
      @key = ENV['ITU_API_KEY']
    end

    # My custom caching pipeline used for translation alignment
    # The real fun is in named_entities method.
    # Type may be formal or noisy.
    def self.cts_pipeline(input, options = {:type => :formal})
      self.named_entities(input).tap { |ne|
        self.send(:"DepParser#{options[:type].capitalize}",
                  ne.each_with_index.map{ |item, idx|
                    Array.new.tap do |s|
                      s << (idx+1)
                      s << item[:raw_content]
                      s << item[:stem]
                      s << item[:pos]
                      s << item[:pos]
                      s << (item[:pos_v].blank? ? '_' : item[:pos_v].join('|'))
                    end.join("\t")
                  }.join("\n")
        ).split("\n").each_with_index do |dep, idx|
          fields = dep.split("\t")
          ne[idx][:dep] = {:idx => fields[-2].to_i - 1, :as => fields[-1].downcase.to_sym}
        end
      }
    end

    def self.named_entities(input)
      self.ner(String.new.tap { |ns|
          ns << BD_TAG << "\n" << self.disambiguator(String.new.tap { |s|
              m = self.tokenizer(self.deasciifier(input)).
                    map { |token|
                      self.normalize(token)
                    }.
                    map { |norm_token|
                      [norm_token, self.morphanalyzer(norm_token)]
                    }
              s << BS_TAG << "\n"
              s << m.map{|t| t.join(' ').gsub("\n", ' ')}.join("\n")
              s << "\n" << ES_TAG
            }
          )
          ns << ES_TAG << "\n" << ED_TAG
        }
      ).split("\r\n").reject{|l| TAGS.any?{|t| l.include?(t)}}.map do |line|
        fields            = line.split(' ')
        raw_content       = fields[0]
        stem, pos, *pos_v = fields[1].split('+')
        entity            = fields[2]
        {:raw_content => fields[0],
         :stem        => stem,
         :pos         => pos,
         :pos_v       => pos_v,
         :entity      => entity =~ /\Ao\Z/i ? nil : entity.downcase.to_sym,
         :isturkish   => self.isturkish(fields[0])
        }
      end
    end

    class << self
      %i[ner morphanalyzer isturkish morphgenerator tokenizer normalize deasciifier Vowelizer DepParserFormal DepParserNoisy spellcheck disambiguator pipelineFormal pipelineNoisy].each do |meth|
        define_method meth do |input|
          request_args = ActiveSupport::OrderedHash.new.tap { |oh|
            oh[:tool]  = meth
            oh[:token] = api_key
            oh[:input] = input
          }
          response = post('/SimpleApi', :body => request_args)
          case meth
          when :pipelineFormal #, :pipelineNoisy
            Array.new.tap do |a|
              response.split("\n").map{|x| x.split("\t")}.each do |item|
                a << Hash.new.tap do |info|
                  info[:idx]   = item[0].to_i
                  info[:src]   = item[1]
                  info[:root]  = item[2]
                  info[:pos]   = item[3]
                  info[:dep] = {:idx => item[-2].to_i, :as => item[-1].downcase.to_sym}

                  unless item[4] =~ /\d+/ # Relations
                    info[:pos_x] = item[4]
                    info[:pos_v] = item[5]
                  end
                end
              end
            end
          when :isturkish
            !!(response.to_s =~ /true/i)
          when :tokenizer
            response.to_s.split("\n")
          else
            response.to_s
          end
        end
      end
    end
  end
end
