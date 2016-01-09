require 'rjb'
Rjb::load(%w[stanford-postagger.jar stanford-ner.jar].map{|jar| Rails.root.join("lib/ruby-nlp/#{jar}")}.join(":"), ['-Xmx256m'])
CRFClassifier = Rjb::import('edu.stanford.nlp.ie.crf.CRFClassifier')

MaxentTagger  = Rjb::import('edu.stanford.nlp.tagger.maxent.MaxentTagger')
MaxentTagger.init(Rails.root.join('lib/ruby-nlp/left3words-wsj-0-18.tagger').to_s)

Sentence      = Rjb::import('edu.stanford.nlp.ling.Sentence')

module Stanford
  class Nlp
    def initialize
      @classifier = CRFClassifier.getClassifierNoExceptions(Rails.root.join('lib/ruby-nlp/ner-eng-ie.crf-4-conll.ser.gz').to_s)
    end

    def ner(input)
      ts = @classifier.testString(input)
      return nil if ts.blank?
      ts.scan(/[^\/]+\/[A-Z]+/).map(&:strip).map{|w| word, entity = w.split('/'); [word, entity =~ /\Ao\Z/i ? nil : entity.downcase.to_sym]}
    end

    def tag(input)
      ts = MaxentTagger.tagString(input)
      return nil if ts.blank?
      ts.scan(/[^\/]+\/[A-Z]+/).map(&:strip).map{|w| w.split('/')}
    end
  end
end
