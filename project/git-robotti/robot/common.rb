require 'find'
require 'fileutils'

WORKING_DIR = '..'
$last_errors = []

def debug(text)
  #puts "[DEBUG] " + text.to_s
end

def print_status()
  step = get_current_step.to_s
  puts '#################################################'
  puts '######### Your Friendly Git Robot ###############'
  puts '#################################################'
  puts '##                                             ##'
  puts "##        Current progress: #{step} / 13             ##"
  puts '##                                             ##'
  puts '#################################################'
end

def print_commit_conflict_error()
  puts "###"
  puts "###  The Robot committed before you did. Update your working copy."
  puts "###"
end

def get_current_step
  current_step = 0
  errors = []
  get_log_entries.each do |entry|

    if entry[:parents].length > 1
      errors << "ERROR: Expected rebase to have been used, but a merge was found: #{entry[:ref]} \"#{entry[:comment]}\""
    end

    # initial:
    if      entry[:comment] == 'Initial project structure' &&
            entry[:ref] == '7f7cff0bbca7883cdfe4e825074f6d322892640c' &&
            current_step == 0
      current_step = 1
    end

    # initial:
    if      entry[:comment] == 'Assembling a longcat' &&
            entry[:ref] == '76c64059769fb57c545e2c050fcc7bb806cbc347' &&
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
            parent_equals_expected?(entry, errors, 'Command line interface') &&
            current_step == 4
      current_step = 5
    end

    # robot:
    if      entry[:comment] == 'Refactored: renamed constants' &&
            parent_equals_expected?(entry, errors, 'Optimized: use StringBuilder to construct the longcat body, as it can be very loooooooooong') &&
            current_step == 5
      current_step = 6
    end

    # USER:
    if      entry[:comment] == 'Length unit conversions' &&
            parent_equals_expected?(entry, errors, 'Refactored: renamed constants') &&
            tree_equals_expected?(entry[:ref], 'robot/step7', errors) &&
            current_step == 6
      current_step = 7
    end

    # robot:
    if      entry[:comment] == 'Added length unit: Eiffel Tower' &&
            parent_equals_expected?(entry, errors, 'Length unit conversions') &&
            current_step == 7
      current_step = 8
    end

    # USER:
    if      entry[:comment] == 'Specifying Longcat length with natural length units' &&
            parent_equals_expected?(entry, errors, 'Added length unit: Eiffel Tower') &&
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
  rev_list = `git rev-list master --reverse --parents`.split("\n")
  rev_list.each do |line|
    s = line.split(' ')
    ref = s.shift
    parents = s
    log_entries <<  {:ref => ref,
                     :comment => get_comment(ref),
                     :parents => parents}
  end
  return log_entries
end

def get_comment(ref)
  s = `git show --pretty=format:%s #{ref}`
  return s.split("\n").first
end


def parent_equals_expected?(entry, errors, *expected_parent_comments)
  actual_parent_comments = entry[:parents].map {|ref| get_comment(ref) }
  if actual_parent_comments == expected_parent_comments
    return true
  else
    errors << "ERROR: In commit #{entry[:ref]}: Expected parent commit to be \"#{expected_parent_comments}\" but it was \"#{actual_parent_comments}\""
    return false
  end
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
  Dir.chdir(WORKING_DIR) do
    #`git reset --hard`
    `git checkout -f #{ref} 2>&1`
  end
end

def apply_patch(patch)
  patch = File.expand_path(patch)
  Dir.chdir(WORKING_DIR) do
    #`git am --abort`
    `git am #{patch}`
  end
end


if ENV['GIT_DIR']
  # Current dir is "<reporoot>/.git/", but we need to run reset at "<reporoot>/".
  # Clearing GIT_DIR is needed, or `git reset` will fail with "fatal: Not a git repository: '.'"
  # even after changing the current dir.
  ENV.delete('GIT_DIR')
end
