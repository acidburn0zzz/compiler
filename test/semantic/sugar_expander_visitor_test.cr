require "../test_helper"

module Runic
  class Semantic
    class SugarExpanderVisitorTest < Minitest::Test
      def test_expands_assignment_operators
        node = visit("a += 1").as(AST::Binary)

        assert_equal "=", node.operator
        assert_equal "a", node.lhs.as(AST::Variable).name

        subnode = node.rhs.as(AST::Binary)
        assert_equal "+", subnode.operator
        assert_equal "a", subnode.lhs.as(AST::Variable).name
        assert_equal "1", subnode.rhs.as(AST::Integer).value
      end

      def test_expands_assignment_operators_recursively
        node = visit("a += (b *= 1)").as(AST::Binary)

        assert_equal "=", node.operator
        assert_equal "a", node.lhs.as(AST::Variable).name

        add = node.rhs.as(AST::Binary)
        assert_equal "+", add.operator
        assert_equal "a", add.lhs.as(AST::Variable).name

        assign = add.rhs.as(AST::Binary)
        assert_equal "=", assign.operator
        assert_equal "b", assign.lhs.as(AST::Variable).name

        mul = assign.rhs.as(AST::Binary)
        assert_equal "*", mul.operator
        assert_equal "b", mul.lhs.as(AST::Variable).name
        assert_equal "1", mul.rhs.as(AST::Integer).value
      end

      protected def visitor
        @visitor ||= SugarExpanderVisitor.new
      end
    end
  end
end