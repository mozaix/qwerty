require 'classifier-reborn'
require 'textoken'
require './lib/qwerty/classifier'
require 'word_count_analyzer'
require_relative 'config'

module Qwerty
  class Classifier
    class Bayes < Ruote::Participant
      def on_workitem
        text = workitem.lookup('text.content')
        workitem.fields['classifier']['bayes'] = {
          :text => text,
          :classifications => score(text),
          :score => classify(text)
          # :analizy => text_analize(text,"hyperlink","hyphenated_word","number","date")
        }
        reply
      end

      def score(text)
        textoken = word_tokenizer(text)
        bayes = bayes(textoken)
        textoken.each do |t|
          bayes.train(t, text)
        end
        classifications(text)
      end

      def classifications(text)
        word_hash = @bayes.classifications(text)
        word_hash = word_hash.map { |k, v| [k.downcase, v] }
        word_hash
      end

      def classify(text)
        @bayes.classify_with_score(text)
      end

      def bayes(textoken)
        @bayes ||= ClassifierReborn::Bayes.new(textoken)
      end

      def word_tokenizer(word)
        Textoken(word, exclude: 'punctuations, numerics', more_than: 3).words
      end

      def text_analize(text, *analizelist)
        analizer = WordCountAnalyzer::Analyzer.new(text: text).analyze
        analize = Hash.new      

        analizelist.each do |i|
          if analizer.has_key?(i)
            analize[i] = analizer[i]
          end
        end
        return analize
      end

    end
  end
end