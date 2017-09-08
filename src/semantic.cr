require "../ast"

module Runic
  class Semantic
    abstract class Visitor
      abstract def visit(node)
    end

    DEFAULT_VISITORS = [
      # TODO: add a sugar expander semantic visitor (e.g. 'a += 1' -> 'a = a + 1')
      TypeVisitor,
    ]

    @visitors = [] of Visitor

    def initialize(visitors = DEFAULT_VISITORS)
      @visitors = visitors.map do |klass|
        klass.new.as(Visitor)
      end
    end

    def visit(node : AST::Node)
      @visitors.each(&.visit(node))
    end
  end
end

require "./semantic/*"
