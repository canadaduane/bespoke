require "bespoke/version"
require "bespoke/indexed_collection"
require "bespoke/exportable"

class Bespoke
  attr_reader :collection, :exports

  def initialize(hash)
    @collection = IndexedCollection.new
    hash["index"].each_pair do |name, column|
      @collection.index name, column
    end
    @exports = {}
    hash["export"].each_pair do |output_name, exportable_configs|
      outputs = @exports[output_name] = []
      exportable_configs.each do |config|
        config.each_pair do |collection_name, attrs|
          outputs << (export = Exportable.new(collection_name))
          (attrs["fields"] || {}).each_pair do |field, template|
            export.field field, template
          end
          (attrs["joins"] || {}).each_pair do |join, template|
            export.join join, template
          end
        end
      end
    end
  end

  def add(type, object)
    @collection.add(type, object)
  end

  def export(name, &block)
    @exports[name].each do |e|
      e.export(@collection.collections, &block)
    end
  end
end