require 'docile'

class Bespoke
  class IndexedCollection
    attr_reader :collections
    
    def initialize
      @index_columns = {}
      @collections = {}
    end

    def proc_for_key(key)
      return Proc.new{ |x| nil } unless key
      key = key.first if key.is_a?(Array) and key.size == 1
      if key.is_a?(Array)
        Proc.new{ |x| key.map{ |k| (x[k] rescue x.send(k)) } }
      else
        Proc.new{ |x| (x[key] rescue x.send(key)) }
      end
    end

    def index(collection_name, index_key_method=nil, &block)
      col_sym = collection_name.to_sym
      @index_columns[col_sym] = block || proc_for_key(index_key_method)
      @collections[col_sym] = {}
    end

    def add(collection_name, object)
      col_sym = collection_name.to_sym
      key_from_object = @index_columns[col_sym]
      key = key_from_object.call(object)
      begin
        @collections[col_sym][key] = object
      rescue NoMethodError
        raise "Can't find collection #{col_sym} with key #{key}"
      end
    end

    def find(collection_name, key)
      if collection = @collections[collection_name.to_sym]
        collection[key]
      end
    end
  end
end
