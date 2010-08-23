require 'find'
require 'fileutils'

REPO_DIR = ARGV[0]
WORKING_DIR = REPO_DIR + '/tmp'
$stdout = STDERR # svn hooks do not print stdout
$last_errors = []

def debug(text)
  #puts "[DEBUG] " + text.to_s
end

def print_status()
  step = get_current_step.to_s
  puts '#################################################'
  puts '######### Your Friendly SVN Robot ###############'
  puts '#################################################'
  puts '##                                             ##'
  puts "##        Current progress: #{step} / 13             ##"
  puts '##                                             ##'
  puts '#################################################'
end

def print_commit_conflict_error()
  puts "Commit Failed"
  puts "svn: Out of date"
  puts "The Robot committed before you did. Update your working copy."
end

def get_current_step
  current_step = 0
  errors = []
  get_log_entries.each do |entry|

    # initial:
    if      entry[:comment] == 'Initial project structure' &&
            current_step == 0
      current_step = 1
    end

    # initial:
    if      entry[:comment] == 'Assembling a longcat' &&
            current_step == 1
      current_step = 2
    end

    # USER:
    if      entry[:comment] == 'Command line argument parsing' &&
            tree_equals_expected?(entry[:ref], 'robot/step3', errors) &&
            current_step == 2
      current_step = 3
    end

    # robot:
    if      entry[:comment] == 'Command line interface' &&
            current_step == 3
      current_step = 4
    end

    # robot:
    if      entry[:comment] == 'Optimized: use StringBuilder to construct the longcat body, as it can be very loooooooooong' &&
            current_step == 4
      current_step = 5
    end

    # robot:
    if      entry[:comment] == 'Refactored: renamed constants' &&
            current_step == 5
      current_step = 6
    end

    # USER:
    if      entry[:comment] == 'Length unit conversions' &&
            tree_equals_expected?(entry[:ref], 'robot/step7', errors) &&
            current_step == 6
      current_step = 7
    end

    # robot:
    if      entry[:comment] == 'Added length unit: Eiffel Tower' &&
            current_step == 7
      current_step = 8
    end

    # USER:
    if      entry[:comment] == 'Specifying Longcat length with natural length units' &&
            tree_equals_expected?(entry[:ref], 'robot/step9', errors) &&
            current_step == 8
      current_step = 9
    end

    # robot:
    if      entry[:comment] == 'Longcat is looooooooooooooooong' &&
            current_step == 9
      current_step = 10
    end

    # robot:
    if      entry[:comment] == 'User friendly error messages' &&
            current_step == 10
      current_step = 11
    end

    # robot:
    if      entry[:comment] == 'Distribution archive and startup files' &&
            current_step == 11
      current_step = 12
    end

    # robot:
    if      entry[:comment] == 'Release 1.0' &&
            current_step == 12
      current_step = 13
    end
  end
  $last_errors = errors
  return current_step
end

def get_log_entries
  log_entries = []
  latest_rev = `svnlook history .`.split("\n")[2].strip.to_i
  (1..latest_rev).each do |rev|
    revision_comment = get_comment(rev)
    
    # include only latest
    log_entries.each do |le|
      log_entries.delete le if le[:comment] == revision_comment
    end
    
    log_entries << {:ref => rev,
                    :comment => get_comment(rev)}
  end

  return log_entries
end

def get_comment(ref)
  s = `svnlook log . -r #{ref}`
  return s.strip
end


def tree_equals_expected?(ref, expected_dir, errors)
  checkout(ref)
  Find.find(expected_dir) do |path|
    if File.file?(path)
      base_path = path.sub(expected_dir + '/', '')
      expected = expected_dir + '/' + base_path
      actual = WORKING_DIR + '/' + base_path
      #debug base_path
      #debug expected
      #debug actual
      if !File.file?(actual)
        errors << "ERROR: File '#{base_path}' in commit '#{ref}'"
        errors << "       Expected a file, but it does not exist"
        return false
      end
      diffs = get_differences(expected, actual)
      if !diffs.empty?
        errors << "ERROR: File '#{base_path}' in commit '#{ref}'"
        errors << "       File contents does not equal what was expected:"
        diffs.each  {|diff| errors << diff }
        return false
      end
    end
  end
  return true
end

def get_differences(expected, actual)
  expected_lines = IO.readlines(expected)
  actual_lines = IO.readlines(actual)
  diffs = []
  for i in 0 .. [expected_lines.length, actual_lines.length].max - 1 do
    expected = expected_lines[i]
    actual = actual_lines[i]
    expected = expected ? expected.strip : ""
    actual = actual ? actual.strip : ""
    if expected != actual
      diffs << "line #{i}:\n" +
              "  expected: #{expected}\n" +
              "    actual: #{actual}"
    end
  end
  return diffs
end


def checkout(ref)
  system("rm -rf #{WORKING_DIR}")
  system("svn checkout -r #{ref} file://#{REPO_DIR} #{WORKING_DIR}")
end

def apply_patch(patch)
  patch = File.expand_path(patch)
  Dir.chdir(WORKING_DIR) do
    system("patch -p1 < #{patch}")
  end
end

def commit_all(message)
  Dir.chdir(WORKING_DIR) do
    Dir.glob("**/*").each do |f|
      system("svn add #{f} 2>/dev/null")
    end
    robolock()
    system("svn commit -m '#{message}' --username 'robottiruttunen'")
    robounlock()
  end
end

def robolock
  File.new("#{REPO_DIR}/robolock", "w")
end

def robounlock
  File.delete("#{REPO_DIR}/robolock")
end
