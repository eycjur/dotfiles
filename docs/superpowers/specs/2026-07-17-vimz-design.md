# vimz: fzf でファイルを選んで vim で開く

## 目的

カレントディレクトリ以下（サブディレクトリ含む）からファイルを fzf で単一選択し、`vim` で開く `vimz` コマンドを追加する。あわせて、既存の `fd` / `bat` 前提の fzf デフォルト設定を `find` / `cat` に寄せる（シェルエイリアスに任せる）。

## 要件

- コマンド名: `vimz`（キーバインドなし）
- 単一選択のみ（`--no-multi`）
- 検索範囲: カレント以下の通常ファイル（再帰、`.git` 配下は除外）
- プレビュー: `cat {}`（`cat`→`bat` 等のエイリアスに委ねる）
- 選択後: `vim "$selected_file"` で開く（`vim`→`nvim` 等のエイリアスに委ねる）
- キャンセル（空選択）時は何もしない
- クエリ初期値: 既存の `_fzf_query`（`LBUFFER`）を使う

## 非要件

- 複数選択
- キーバインド
- `fd` / `bat` の明示利用やフォールバック分岐
- ディレクトリ選択・ディレクトリへの cd

## 変更ファイル

`shell/fzf.sh` のみ。

### 1. 既存デフォルトの簡略化

削除する:

```sh
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
fi
if command -v bat >/dev/null 2>&1; then
  export FZF_PREVIEW_COMMAND='bat --style=numbers --line-range=:500'
fi
```

置き換え:

```sh
export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/.git/*"'
```

`FZF_PREVIEW_COMMAND` は設定しない（各コマンドの `--preview`、または fzf デフォルトに任せる）。

### 2. vimz の追加

既存の `*z` パターンに合わせ、関数 + alias を追加する。

```sh
function select-vim-file() {
    local selected_file
    selected_file=$(fzf --no-multi --query "$(_fzf_query)" --prompt "FILE>" --preview 'cat {}')
    if [ -n "$selected_file" ]; then
        vim "$selected_file"
    fi
}
alias vimz=select-vim-file
```

ファイル先頭の使い方コメントに次を追記する:

```text
# vimz: カレント以下からファイルを選んで vim で開く
```

## データフロー

1. ユーザーが `vimz` を実行する
2. fzf が `FZF_DEFAULT_COMMAND`（`find`）でファイル一覧を取得する
3. ユーザーが1件選択する（プレビューは `cat`）
4. 選択パスが空でなければ `vim` で開く

## エラー・エッジケース

- Esc / Ctrl-C 等で未選択 → 何もしない（既存 `*z` と同じ）
- `find` が重い巨大ツリー → 許容（本変更のスコープ外。必要なら後で除外や `fd` 再導入を検討）

## テスト計画

1. シェルを再読み込み（または `source shell/fzf.sh`）
2. 適当なリポジトリで `vimz` を実行し、ファイル一覧が出ること
3. プレビューにファイル内容が出ること
4. 選択すると vim/nvim で開くこと
5. キャンセルするとシェルに戻り、何も開かないこと
6. `.git` 配下のファイルが一覧に出ないこと
