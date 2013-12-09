module XCPretty
  module Printer

    class RSpec
      
      include Printer

      FAIL = "F"
      PASS = "."

      def pretty_format(text)
        case text
        when PASSING_TEST_MATCHER
          colorize? ? green(PASS) : PASS
        when FAILING_TEST_MATCHER
          colorize? ? red(FAIL) : FAIL
        else
          ""
        end
      end

      private

      def format(output)
        if colorize?
          return case output
          when FAIL then red(output)
          when PASS then green(output)
          else
            output
          end
        end
        output
      end

      def test_summary(executed_message)
        formatted_failures = failures.map do |f|
          reason = colorize? ? red(f[:failure_message]) : f[:failure_message]
          file   = colorize? ? link(f[:file]) : f[:file]
          snippet =  parse_snippet(f[:file]) || ""

          "#{f[:test_case]}, #{reason}\n→ #{snippet}\n#{file}"
        end.join("\n\n")
        final_message = if colorize?
          failures.any? ? red(executed_message) : green(executed_message)
        else
          executed_message
        end
        text = [formatted_failures, final_message].join("\n\n\n").strip
        "\n\n#{text}"
      end

      def formatter
        @formatter ||=  formatter = Rouge::Formatters::Terminal256.new(theme: 'github')
      end

      def lexer
        @lexer ||= lexer = Rouge::Lexers::ObjectiveC.new
      end

      def parse_snippet file
        path, lineno = file.split(':')
        if File.exist? path
          f = File.new(path)
          (lineno.to_i - 1).times { f.gets }
          snippet = f.gets.strip
          colorize? ? formatter.format(lexer.lex(snippet)) : snippet
        end
      end
    end
  end
end
