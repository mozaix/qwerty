require_relative 'text'
require_relative 'config'
module Qwerty
 class Text
   class QuranSimple < Ruote::Participant
     attr_accessor :collection, :row, :random_num

     def on_workitem
         workitem.fields['text'][:quran_simple] = {
             :source => "http://tanzil.info",
             :languageList => Qwerty.configuration.language_list,
           }.merge!(ayah_hash)
          workitem.fields['text']['content'] = row[:verse][:en_ahmedali]
          reply 
     end

     def ayah_hash
          language = Qwerty.configuration.language_list
          text = Hash.new
          language.each_key { |key| text = execute(language[key][:dir], key) }
          return text
      end

      def execute(dir, key)
          coll_key = "@collection_#{key}"
          instance_variable_set(coll_key, Array.new) unless instance_variable_defined? coll_key 
          @collection = instance_variable_get "@collection_#{key}"
          read_file dir if @collection.empty?
          random_generate key
      end

      def read_file(file_name)  
          File.read(file_name).each_line do |line|
            line.gsub!(/\n/, '')
            surah, ayah, verse = line.split(/\|/)
            @collection << { surah: surah, ayah: ayah, verse: verse}
          end
      end

      def random_generate(key)
          @random_num = rand(collection.size) if row == nil
          @row = collection[random_num]
         (@verse ||= Hash.new).merge!({ key => row[:verse] })
          row[:verse] = @verse
          collection.delete_at(random_num)
          return row
      end
   end
 end
end