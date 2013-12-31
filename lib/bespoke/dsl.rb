require "bespoke"

def indexed_collection(&block)
  Docile.dsl_eval(Bespoke::IndexedCollection.new, &block)
end

def exportable(name, &block)
  Docile.dsl_eval(Bespoke::Exportable.new(name), &block)
end
