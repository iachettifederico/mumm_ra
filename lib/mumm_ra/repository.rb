module MummRa
  class Repository
    include Enumerable

    def initialize(args={})
      @source     = args.fetch(:source)
      @main_class = args.fetch(:main_class)
    end

    def all
      @all ||= source.values
    end

    def each
      all.each do |value|
        yield value
      end
    end

    def [](key)
      source[key]
    end

    def construct_from_object(obj)
      return obj if obj.is_a? main_class
      return main_class.new(obj) if obj.is_a?(Hash)
      attrs = {}
      main_class.members.each do |attr|
        attrs[attr] = obj.send(attr)
      end
      main_class.new(attrs)
    end

    private
    attr_reader :source
    attr_reader :main_class

  end
end
