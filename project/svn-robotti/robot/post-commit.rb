#!/usr/bin/ruby

debug '------------------------------------------------------------------------'
debug 'Hello: post-commit'



current_step = get_current_step
if current_step == 3
  checkout('HEAD')
  apply_patch('robot/0004-Command-line-interface.patch')
  commit_all('Command line interface')
end
if current_step == 9
  checkout('HEAD')
  apply_patch('robot/0010-Longcat-is-looooooooooooooooong.patch')
  commit_all('Longcat is looooooooooooooooong')
  apply_patch('robot/0011-User-friendly-error-messages.patch')
  commit_all('User friendly error messages')
  apply_patch('robot/0012-Distribution-archive-and-startup-files.patch')
  commit_all('Distribution archive and startup files')
  apply_patch('robot/0013-Release-1.0.patch')
  commit_all('Release 1.0')
end


#debug 'current step: ' + get_current_step.to_s
debug '------------------------------------------------------------------------'

if $last_errors != []
  print_status()
  $last_errors.each {|error| puts error}
  exit 1
end
