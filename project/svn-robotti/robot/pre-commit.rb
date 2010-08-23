#!/usr/bin/ruby

debug '------------------------------------------------------------------------'
debug 'Hello: pre-commit'

current_step = get_current_step
debug 'pre-commit current_step: ' + current_step.to_s


if current_step == 4
  checkout('HEAD')
  apply_patch('robot/0005-Optimized-use-StringBuilder-to-construct-the-longcat.patch')
  commit_all('Optimized: use StringBuilder to construct the longcat body, as it can be very loooooooooong')
  apply_patch('robot/0006-Refactored-renamed-constants.patch')
  commit_all('Refactored: renamed constants')
  print_commit_conflict_error()
  exit 1
end
if current_step == 7
  checkout('HEAD')
  apply_patch('robot/0008-Added-length-unit-Eiffel-Tower.patch')
  commit_all('Added length unit: Eiffel Tower')
  print_commit_conflict_error()
  exit 1
end


#debug 'current step: ' + get_current_step.to_s
debug '------------------------------------------------------------------------'

#exit(1)
