require 'csv'
require 'docile'
require 'mustache'
require 'logger'

class Bespoke
  class Error < StandardError; end
  MissingTable = Class.new(Error)

  class Exportable
    attr_accessor :name, :fields, :joins

    def initialize(name, logger=nil)
      @name = name.to_sym
      @fields = {}
      @joins = {}
      @helpers = {}
      @logger = logger || Logger.new(STDERR)
    end

    class HelperClass
      def initialize(helpers, context)
        @helpers, @context = helpers, context
      end

      def has_key?(key)
        @helpers.has_key?(key) ||
        @context.has_key?(key)
      end

      def [](key)
        if @helpers.has_key?(key)
          @helpers[key].call(@context)
        elsif @context.has_key?(key)
          @context[key]
        else
          super(key)
        end
      end
    end

    def headers
      @fields.keys
    end

    def helper(name, &block)
      @helpers[name] = block
    end

    def field(name, template_string)
      fields[name] = Mustache::Template.new(template_string)
    end

    def join(name, key)
      joins[name] = key
    end

    def export(hashes={}, &block)
      raise "hashes missing #{@name.inspect} (of: #{hashes.keys.inspect})" unless hashes.has_key?(@name)
      hashes[@name].map do |main_key, row|
        context = { @name => row }
        context[:helper] = HelperClass.new(@helpers, context)
        @joins.each_pair do |join_name, key|
          if other_table = hashes[join_name.to_sym]
            if other_table.has_key?(row[key])
              context[join_name.to_sym] = other_table[row[key]]
            else
              @logger.warn "Expected foreign key #{key} with value #{row[key]} in table #{join_name} (#{row.inspect})"
            end
          else
            raise MissingTable, "Expected #{join_name}"
          end
        end
        fields.map do |name, template|
          Mustache.render(template, context)
        end.tap do |output_row|
          yield output_row if block_given?
        end
      end
    end
  end
end
