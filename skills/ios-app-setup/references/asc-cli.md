# App Store Connect CLI（`asc`）運用

公式 App Store Connect API を `asc` CLI から呼び、文面反映・録画添付・ビルド紐付け・事前検証を行う。

## 運用原則

- **ASC を基準にする**: 更新・再提出では、リポジトリの下書きではなく ASC の現行値を読み出して土台にする。書き込み後に同じ本文を `marketing/app-store-metadata.md` へ書き戻して揃える
- **読む → 差分を見せる → 書く → 読み戻す**: 書き込み前に必ずユーザーへ差分を提示する。書き込み後は読み戻して内容が一致することを確認する
- **提出直前で止める**: `asc validate` までは進めてよい。提出確定（`submit`）はユーザー確認後に実行する
- **API 非対応はブラウザ**: Resolution Center への返信、App のプライバシー、規制関連の申告は ASC 画面で操作する

## 認証・確認

```sh
asc telemetry disable
asc auth login --name <name> --key-id <keyId> --issuer-id <issuerId> --private-key <AuthKey.p8>
# キーチェーンがない環境（sandbox 等）では --bypass-keychain を付ける
asc auth status --validate
```

## 主要コマンド

| 用途 | コマンド |
|------|----------|
| バージョン ID・審査状態の確認 | `asc versions list --app <appId>` / `asc review status` / `asc review doctor` |
| 文面の読み出し（概要・キーワード等） | `asc localizations list --version <versionId>` |
| 審査メモ・添付の読み出し | `asc review details-get --id <reviewDetailId>` / `asc review attachments-list --review-detail <id>` |
| 文面の更新 | `asc localizations update --id <locId> --description "$(cat desc.txt)"`（必要に応じて他フィールドも指定） |
| 審査メモの更新（4,000字以内） | `asc review details-update --id <id> --notes "$(cat notes.txt)"` |
| 画面録画の添付 | `asc review attachments-upload --review-detail <id> ...` |
| ビルド紐付け | `asc builds list` で `VALID` を待つ → `asc versions attach-build --version-id <versionId> --build-id <buildId>` |
| 提出前チェック | `asc validate --app <appId> --version <version>` |
