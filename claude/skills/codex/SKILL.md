---
name: codex
description: OpenAI Codex CLIを使用して、難解な問題を解決するための調査を実行し、ヒントを取得します。解決が難しい問題に対して、多角的な視点で考えるための壁打ちを行う相手として利用することもできます。使用場面例：解消が難しい問題の調査、コードレビュー依頼、複雑なバグの調査
---

# Codex

Codex CLIを使用してコードレビュー・分析を実行するスキル。

## 実行コマンド

codex exec --full-auto --sandbox read-only  -skip-git-repo-check "<request>"

## パラメータ

| パラメータ | 説明 |
|-----------|------|
| `--full-auto` | 完全自動モードで実行 |
| `--sandbox read-only` | 読み取り専用サンドボックス（安全な分析用） |
| `--skip-git-repo-check` | Gitリポジトリであるかのチェックをスキップ |
| `"<request>"` | 依頼内容（日本語可） |

## 使用例

### バグ調査
codex exec --full-auto --sandbox read-only --skip-git-repo-check "認証処理でエラーが発生する原因を調査してください"

### コードレビュー
codex exec --full-auto --sandbox read-only --skip-git-repo-check "このプロジェクトのコードをレビューして、改善点を指摘してください"
