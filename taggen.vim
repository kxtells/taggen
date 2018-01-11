" THIS IS THE TAGGEN PACKAGE
" tags are generated in a local directory, and then appended to the tags variable
" at the end, so tags in the current directory have priority

" delete functions already loaded
if exists("TAGGEN_LOADED")
	echo "delete"
	delfun s:TagGenFunc
	delfun s:TagDelFunc
	delfun s:TagDelAllFunc
	delfun s:TagLoadFunc
endif

" Get possible user defined variables
if !exists("TG_tagdir")
	let g:TG_tagdir=$HOME . "/.vim/TagGen/"
endif


:let s:cwd = getcwd()
:let s:tagdir  =  g:TG_tagdir . s:cwd
:let s:tagfile =  g:TG_tagdir . s:cwd . "/tags"
:let s:csofile =  g:TG_tagdir . s:cwd . "/cscope.out"
:let s:csffile =  g:TG_tagdir . s:cwd . "/cscope.files"

" Check existance of all needed functions
:if exists("*mkdir")
: echo "Mkdir present"
:endif


" Get directory for tags

: echo s:cwd
: echo s:tagdir

:if !isdirectory(s:tagdir)
	:call mkdir(s:tagdir, "p", 0755)
:endif

function s:TagGenFunc()
	echo "Generating tags"
	echo 'ctags -R -h=".c.h" -f ' . fnameescape(s:tagfile) . " " . s:cwd
	: call system('ctags -R -h=".c.h" -f ' . fnameescape(s:tagfile) . " " . fnameescape(s:cwd))
	echo "Ctags exited with " . v:shell_error

	echo "Finding files for cscope..."
	echo "find " . s:cwd . " -name '*.[ch]' > " . s:csffile
	: call system("find " . fnameescape(s:cwd) . " -name '*.[ch]' > " . fnameescape(s:csffile))
	echo "Find exited with " . v:shell_error

	echo "Generating cscope file"
	echo "cscope -b -i " . s:csffile . " -f " . s:csofile
	: call system("cscope -b -i " . fnameescape(s:csffile) . " -f " . fnameescape(s:csofile))
	echo "cscope exited with " . v:shell_error

	call s:TagLoadFunc()
endfunction

function s:TagDelFunc()
	echo "Deleting Tag files"
	: call system('rm -f ' . fnameescape(s:tagfile))
	: call system('rm -f ' . fnameescape(s:csffile))
	: call system('rm -f ' . fnameescape(s:csofile))
	echo "RM exited with " . v:shell_error
endfunction

function s:TagDelAllFunc()
	echo "Deleting All Tag files"
	: call system('rm -f ' . fnameescape(s:tagdir))
	echo "RM exited with " . v:shell_error
endfunction

function s:TagLoadFunc()
	" Load the TAGS and CSCOPE databases
	exec "set tags +=" . fnameescape(s:tagfile)
	exec "cscope add " . fnameescape(s:csofile)
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
