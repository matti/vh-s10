#!/usr/bin/ruby

debug '------------------------------------------------------------------------'
debug 'Hello: post-receive'



current_step = get_current_step
if current_step == 3
  checkout('master')
  apply_patch('robot/0004-Command-line-interface.patch')
end
if current_step == 9
  checkout('master')
  apply_patch('robot/0010-Longcat-is-looooooooooooooooong.patch')
  apply_patch('robot/0011-User-friendly-error-messages.patch')
  apply_patch('robot/0012-Distribution-archive-and-startup-files.patch')
  apply_patch('robot/0013-Release-1.0.patch')
end


#debug 'current step: ' + get_current_step.to_s
debug '------------------------------------------------------------------------'

print_status()
$last_errors.each {|error| puts error}
