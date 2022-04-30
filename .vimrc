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

" jjをescにバインド
inoremap <silent> jj <ESC>

" インデントをスペース4つ
set expandtab
set tabstop=4
set shiftwidth=4

" クリップボードを共有
set clipboard+=unnamedplus
if system('uname -a | grep microsoft') != ''
    augroup myYank
        autocmd!
        autocmd TextYankPost * :call system('clip.exe', @")
    augroup END
endif

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

