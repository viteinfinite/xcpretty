module XCPretty
  class KIFHTML

    include XCPretty::FormatMethods
    FILEPATH = 'build/reports/kif_tests.html'
    KIF_SCREENSHOTS = 'build/reports'
    TEMPLATE = File.expand_path('../../../../assets/kif_report.html.erb', __FILE__)

    def load_dependencies
      unless @@loaded ||= false
        require 'fileutils'
        require 'pathname'
        require 'erb'
        @@loaded = true
      end
    end

    def initialize(options)
      load_dependencies
      @test_suites = {}
      @filepath    = options[:path] || FILEPATH
      @parser      = Parser.new(self)
      @test_count  = 0
      @fail_count  = 0
    end

    def handle(line)
      @parser.parse(line)
    end

    def format_failing_test(suite, test_case, reason, file)
      add_test(suite, {:name => test_case, :failing => true,
        :reason => reason, :file => file, :snippet => formatted_snippet(file)})
    end

    def format_passing_test(suite, test_case, time)
      add_test(suite, {:name => test_case, :time => time})
    end

    def finish
      FileUtils.mkdir_p(File.dirname(@filepath))
      write_report
    end

    private

    def formatted_snippet filepath
      file, line = filepath.split(':')
      f = File.open(file)
      line.to_i.times { f.gets }
      text = $_.strip
      f.close
      Syntax.highlight(text, "-f html -O style=colorful -O noclasses")
    rescue
      nil
    end

    def add_test(suite_name, data)
      @test_count += 1
      @test_suites[suite_name] ||= {:tests => []}
      @test_suites[suite_name][:tests] << data
      if data[:failing]
        @test_suites[suite_name][:failing] = true
        @fail_count += 1
      end
    end

    def write_report
      load_screenshots
      # TODO: Create gif from pngs
      File.open(@filepath, 'w') do |f|
        test_suites = @test_suites
        fail_count  = @fail_count
        test_count  = @test_count
        erb = ERB.new(File.open(TEMPLATE, 'r').read)
        f.write erb.result(binding)
      end
    end

    def load_screenshots
      Dir.foreach(KIF_SCREENSHOTS) do |item|
        next if item == '.' or item == '..' or File.extname(item) != ".png"
        # TODO: compare and store image filename to test name
        puts item
      end
    end
  end
end