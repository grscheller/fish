function ud --description 'Jump up multiple directories, default is 1'
   set -l upDir ..
   set -l maxUp (math (string split / (pwd) | count) - 1)
   set -l nDirs
   set -l targetName ''

   if string match -qr -- '^[1-9]\d*$' $argv[1]
      # If first argument a number, limit search to that number
      # of directories up and set targetName to second argument.
      set nDirs $argv[1]
      if [ $nDirs -gt $maxUp ]
          set nDirs $maxUp
      end
      test (count $argv) -gt 1 && set targetName $argv[2]
   else
      # Otherwise set nDirs to $maxUp and set targetName
      # to first argument, ignore second argument.
      set nDirs $maxUp
      test (count $argv) -gt 0 && set targetName $argv[1]
   end

   set -l cnt 1
   if [ -z $targetName ]
      # Setup number of directories to jump if no target given
      while [ $cnt -le $nDirs ]
         set upDir ../$upDir
         set cnt (math $cnt + 1)
      end
   else
      # First look for exact match.
      while [ $cnt -le $nDirs ]
         test -e $upDir/$targetName && break
         set upDir ../$upDir
         set cnt (math $cnt + 1)
      end
      # Next look for leading string match, select first one found.
      set cnt 1
      set upDir ..
      set -l targetsFound
      set -l upDirPat
      while [ $cnt -le $maxUp ]
         if test (count $upDir/$targetName*) -gt 0
            set targetsFound $upDir/$targetName*
            set targetName $targetsFound[1]
            set upDirPat (string replace -a '.' '\\.' $upDir)
            set targetName (string replace -r $upDirPat '' $targetName)
            break
         end
         set upDir ../$upDir
         set cnt (math $cnt + 1)
      end
   end

   set -l target $upDir/$targetName
   if [ ! -e "$target" ]
      # Let user know if target not found in any parent directory.
      printf '"%s" not found in any parent directory\n' $targetName >&2
      return 2
   else if [ -d $target ]
      # Drop into target if a directory.
      cd "$target"
   else
      # Otherwise go directly to parent directory of target.
      cd $upDir
   end

   return 0
end
