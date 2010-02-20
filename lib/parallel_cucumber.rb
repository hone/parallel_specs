require File.join(File.dirname(__FILE__), 'parallel_tests')

class ParallelCucumber < ParallelTests
  def self.run_tests(test_files, process_number)
    color = ($stdout.tty? ? 'export AUTOTEST=1 ;' : '')#display color when we are in a terminal
    cmd = "export TEST_ENV_NUMBER=#{test_env_number(process_number)} ; #{color} #{executable} #{test_files*' '}"
    execute_command(cmd)
  end

  def self.executable
    if File.file?(".bundle/environment.rb")
      "bundle exec cucumber"
    elsif File.file?('Gemfile')
      dir = "bin"

      File.open('Gemfile') do |file|
        bin_path_line = file.readlines.find do |line|
          /^bin_path/.match(line)
        end
        if bin_path_line
          match_data = /^bin_path "(.+)"/.match(bin_path_line)
          dir = match_data[1]
        end
      end

      "#{dir}/cucumber"
    elsif File.file?("script/cucumber")
      "script/cucumber"
    else
      "cucumber"
    end
  end

  protected

  def self.line_is_result?(line)
    line =~ /^\d+ (steps|scenarios)/
  end
  
  def self.line_is_failure?(line)
    line =~ /^\d+ (steps|scenarios).*(\d{2,}|[1-9]) failed/
  end

  def self.find_tests(root)
    Dir["#{root}**/**/*.feature"]
  end
end
