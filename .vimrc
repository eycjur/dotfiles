" viとの互換性を無効にする(INSERT中のカーソルキーが有効、コントロールコードを無効)
set nocompatible

" 括弧入力時の対応する括弧を表示
set showmatch

" 行番号の表示
set number
" 保存し内で終了するときに確認ダイアログ
set confirm

" Windowsでパスの区切り文字をスラッシュで扱う
set shellslash

" リアルタイム検索
set incsearch

" 自動でインデントを整える
set smartindent

" 自動補完
set completeopt=menu,menuone,noselect
if has('patch-9.1.1590')
  set autocomplete
endif

" jjをescにバインド
" inoremap: insertモードのみ
" noremap: normal/visualモード
" noremap!: insert/commandモード
inoremap <silent> jj <ESC>

" emacsのキーバインド
noremap <C-p> <Up>
noremap <C-n> <Down>
noremap <C-b> <Left>
noremap <C-f> <Right>
noremap <C-a> <HOME>
noremap <C-e> <END>

noremap! <C-p> <Up>
noremap! <C-n> <Down>
noremap! <C-b> <Left>
noremap! <C-f> <Right>
noremap! <C-a> <HOME>
noremap! <C-e> <END>

" インデントをスペース4つ
set expandtab
set tabstop=4
set shiftwidth=4

" クリップボードを共有
set clipboard&
set clipboard^=unnamed

if has("nvim")
    " nvimのみの設定
    " カラーを変更する
    set termguicolors
else
    " vimのみの設定
    " コメントの色を黄色
    hi Comment ctermfg=3

    " 検索時に最後まで行ったら最初に戻る
    set wrapscan

    " 検索結果をハイライト表示
    set hlsearch

    "BSで削除できるものを指定する
    " indent  : 行頭の空白
    " eol     : 改行
    " start   : 挿入モード開始位置より手前の文字
    set backspace=indent,eol,start

    " シンタックスハイライトの有効化
    syntax enable
endif
