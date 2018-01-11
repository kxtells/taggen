" THIS IS THE TAGGEN PACKAGE
" tags are generated in a local directory, and then appended to the tags variable
" at the end, so tags in the current directory have priority

" delete functions already loaded
if exists("TAGGEN_LOADED")
	echo "delete"
	delfun s:TagGenFunc
	delfun s:TagDelFunc
endif

:let i = 1
:while i < 5
:  echo "count is" i
:  let i += 1
:endwhile

:let s:cwd = getcwd()
:let s:tagdir  =  $HOME . "/.vim/tags/" . s:cwd
:let s:tagfile =  $HOME . "/.vim/tags/" . s:cwd . "/tags"
:let s:csofile =  $HOME . "/.vim/tags/" . s:cwd . "/cscope.out"
:let s:csffile =  $HOME . "/.vim/tags/" . s:cwd . "/cscope.files"

" Check existance of all needed functions
:if exists("*mkdir")
: echo "Mkdir present"
:endif


" Get directory for tags

: echo s:cwd
: echo s:tagdir

:if isdirectory(s:tagdir)
	: echo "Exists"
:else
	:call mkdir(s:tagdir, 0755)
:endif

function s:TagGenFunc()
	" CALL ctags/cscope
	echo "Generating tags"
	echo 'ctags -R -h=".c.h" -f ' . shellescape(s:tagfile) . " " . s:cwd
	: call system('ctags -R -h=".c.h" -f ' . shellescape(s:tagfile) . " " . shellescape(s:cwd))
	echo "Ctags exited with " . v:shell_error
	exec "set tags +=" . s:tagfile

	echo "Finding files for cscope..."
	echo "find " . s:cwd . " -name '*.[ch]' > " . s:csffile
	: call system("find " . shellescape(s:cwd) . " -name '*.[ch]' > " . shellescape(s:csffile))
	echo "Find exited with " . v:shell_error

	echo "Generating cscope file"
	echo "cscope -b -i " . s:csffile . " -f " . s:csofile
	: call system("cscope -b -i " . shellescape(s:csffile) . " -f " . shellescape(s:csofile))
	echo "cscope exited with " . v:shell_error
endfunction

function s:TagDelFunc()
	echo "Deleting Tag files"
	: call system('rm -f ' . shellescape(s:tagfile))
	echo "RM exited with " . v:shell_error
endfunction

if !exists(":TagGen")
	command -nargs=0 TagGen :call s:TagGenFunc()
endif

if !exists(":TagDel")
	command -nargs=0 TagDel :call s:TagDelFunc()
endif


let TAGGEN_LOADED = 1
