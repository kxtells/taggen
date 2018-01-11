" THIS IS THE TAGGEN PACKAGE
" tags are generated in a local directory, and then appended to the tags variable
" at the end, so tags in the current directory have priority

" delete functions already loaded
if exists("TAGGEN_LOADED")
	delfun s:TagGenFunc
	delfun s:TagDelFunc
	delfun s:TagDelAllFunc
	delfun s:TagLoadFunc
endif

" USER DEFINED VARIABLES --- {{{
if !exists("g:taggen_tagdir")
	" Base directory where to store your tags
	let g:taggen_tagdir=$HOME . "/.vim/TagGen/"
endif

if !exists("g:taggen_cscope")
	" Is Cscope available
	let g:taggen_cscope=1
endif

if !exists("g:taggen_ctags")
	" Is Ctags available
	let g:taggen_ctags=1
endif
" --- }}}


:let s:cwd = getcwd()
:let s:tagdir  =  g:taggen_tagdir . s:cwd
:let s:tagfile =  g:taggen_tagdir . s:cwd . "/tags"
:let s:csofile =  g:taggen_tagdir . s:cwd . "/cscope.out"
:let s:csffile =  g:taggen_tagdir . s:cwd . "/cscope.files"

" Check existance of all needed functions
:if exists("*mkdir")
: echo "Mkdir present"
:endif



" Create tag dir if it does not exist
:if !isdirectory(s:tagdir)
	:call mkdir(s:tagdir, "p", 0755)
:endif


" Tag generator function --- {{{
function s:TagGenFunc()
	if g:taggen_ctags == 1
		echo "Generating tags"
		echo 'ctags -R -h=".c.h" -f ' . fnameescape(s:tagfile) . " " . s:cwd
			call system('ctags -R -h=".c.h" -f ' . fnameescape(s:tagfile) . " " . fnameescape(s:cwd))
		echo "Ctags exited with " . v:shell_error

		echo "Finding files for cscope..."
		echo "find " . s:cwd . " -name '*.[ch]' > " . s:csffile
			call system("find " . fnameescape(s:cwd) . " -name '*.[ch]' > " . fnameescape(s:csffile))
		echo "Find exited with " . v:shell_error
	endif


	if g:taggen_cscope == 1
		echo "Generating cscope file"
		echo "cscope -b -i " . s:csffile . " -f " . s:csofile
		: call system("cscope -b -i " . fnameescape(s:csffile) . " -f " . fnameescape(s:csofile))
		echo "cscope exited with " . v:shell_error
	endif

	call s:TagLoadFunc()
endfunction
" --- }}}

" Tag removal functions --- {{{
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
" --- }}}

function s:TagLoadFunc()
	" Load the TAGS and CSCOPE databases
	if g:taggen_ctags == 1
		exec "set tags +=" . fnameescape(s:tagfile)
	endif

	if g:taggen_cscope == 1
		exec "cscope add " . fnameescape(s:csofile)
	endif
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
