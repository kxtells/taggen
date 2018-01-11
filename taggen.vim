" THIS IS THE TAGGEN PACKAGE
" tags are generated in a local directory, and then appended to the tags variable
" at the end, so tags in the current directory have priority

" delete functions already loaded
if exists("TAGGEN_LOADED")
	echo "delete"
	delfun s:TagGenFunc
	delfun s:TagDelFunc
endif

" Get possible user defined variables
"if !exists("TG_tagdir")
"	let TG_tagdir=$HOME . "/.vim/TagGen/"
"fi


:let s:cwd = getcwd()
:let s:tagdir  =  $HOME . "/.vim/TagGen/" . s:cwd
:let s:tagfile =  $HOME . "/.vim/TagGen/" . s:cwd . "/tags"
:let s:csofile =  $HOME . "/.vim/TagGen/" . s:cwd . "/cscope.out"
:let s:csffile =  $HOME . "/.vim/TagGen/" . s:cwd . "/cscope.files"

" Check existance of all needed functions
:if exists("*mkdir")
: echo "Mkdir present"
:endif


" Get directory for tags

: echo s:cwd
: echo s:tagdir

:if !isdirectory(s:tagdir)
	:call mkdir(s:tagdir, 0755)
:endif

function s:TagGenFunc()
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

	cscope add s:csofile
endfunction

function s:TagDelFunc()
	echo "Deleting Tag files"
	: call system('rm -f ' . shellescape(s:tagfile))
	: call system('rm -f ' . shellescape(s:csffile))
	: call system('rm -f ' . shellescape(s:csofile))
	echo "RM exited with " . v:shell_error
endfunction

function s:TagDelAllFunc()
	echo "Deleting All Tag files"
	: call system('rm -f ' . shellescape(s:tagdir))
	echo "RM exited with " . v:shell_error
endfunction

function s:TagLoadFunc()
	echo 'ctags -R -h=".c.h" -f ' . shellescape(s:tagfile) . " " . s:cwd
	: call system('ctags -R -h=".c.h" -f ' . shellescape(s:tagfile) . " " . shellescape(s:cwd))
	echo "Ctags exited with " . v:shell_error
	exec "set tags +=" . s:tagfile

	cscope add s:csofile
endfunction

"
" Commands provided by this plugin
"
if !exists(":TagGen")
	command -nargs=0 TagGen :call s:TagGenFunc()
endif

if !exists(":TagDelAll")
	command -nargs=0 TagDelAll :call s:TagDelAllFunc()
endif

if !exists(":TagDel")
	command -nargs=0 TagDel :call s:TagDelFunc()
endif

if !exists(":TagLoad")
	command -nargs=0 TagLoad :call s:TagLoadFunc()
endif

let TAGGEN_LOADED = 1
