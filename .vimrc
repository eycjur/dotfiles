" viとの互換性を無効にする(INSERT中にカーソルキーが有効になる)
set nocompatible

" 括弧入力時の対応する括弧を表示
set showmatch

" 検索時に最後まで行ったら最初に戻る
set wrapscan

" 検索結果をハイライト表示
set hlsearch

" クリップボードを共有
set clipboard=unnamed

" Windowsでパスの区切り文字をスラッシュで扱う
set shellslash

" 自動でインデントを整える
set smartindent

"BSで削除できるものを指定する
" indent  : 行頭の空白
" eol     : 改行
" start   : 挿入モード開始位置より手前の文字
set backspace=indent,eol,start

" シンタックスハイライトの有効化
syntax enable

" コメントの色を水色
hi Comment ctermfg=3

" jjをescにバインド
inoremap <silent> jj <ESC>
