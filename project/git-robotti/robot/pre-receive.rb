#!/usr/bin/ruby

debug '------------------------------------------------------------------------'
debug 'Hello: pre-receive'


$refs_to_be_updated = []
while s = gets
  ss = s.chomp.split(" ")
  $refs_to_be_updated << {:old_value => ss[0],
                          :new_value => ss[1],
                          :ref_name => ss[2]}
end
#debug 'params: ' + $refs_to_be_updated.to_s

def will_update(old_comment, new_comment)
  $refs_to_be_updated.each do |update|
    if update[:ref_name] == 'refs/heads/master' &&
            get_comment(update[:old_value]) == old_comment &&
            get_comment(update[:new_value]) == new_comment
      debug 'will_update: '+update.to_s
      debug 'old: '+get_comment(update[:old_value])
      debug 'new: '+get_comment(update[:new_value])
      return true
    end
  end
  return false
end


current_step = get_current_step
debug "pre-receive current_step: " + current_step.to_s
if current_step == 4 &&
        will_update('Command line interface',
                    'Length unit conversions')
  checkout('master')
  apply_patch('robot/0005-Optimized-use-StringBuilder-to-construct-the-longcat.patch')
  apply_patch('robot/0006-Refactored-renamed-constants.patch')
  print_commit_conflict_error()
end
if current_step == 7 &&
        will_update('Length unit conversions',
                    'Specifying Longcat length with natural length units')
  checkout('master')
  apply_patch('robot/0008-Added-length-unit-Eiffel-Tower.patch')
  print_commit_conflict_error()
end


#debug 'current step: ' + get_current_step.to_s
debug '------------------------------------------------------------------------'

#exit(1)
