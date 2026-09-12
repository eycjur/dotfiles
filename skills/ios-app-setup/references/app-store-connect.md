# App Store Connect 入力・提出

「ストアに出したい」「アップデートを提出したい」「審査に落ちた」ときに使う。
各項目の定義・決め方は [app-store-connect-fields.md](app-store-connect-fields.md) を正本とする。画面に新しい項目が現れたら、まずそこに追記してから値を決める。

## 自律実行の原則

- ユーザーから追加情報がなくても、リポジトリ（README・コード・既存の `marketing/app-store-metadata.md`・git log）と本スキルの判断ルールだけで、すべての入力値を決め、metadata を最新化し、提出できる状態まで進める
- ユーザーに確認するのは次だけ。それ以外は決めて報告する
  1. App Store Connect API キー（`ASC_KEY_PATH` / `ASC_KEY_ID` / `ASC_ISSUER_ID`）が環境にないとき
  2. 審査メモに貼る画面録画のリンク（実機録画はこちらでは作れない）
  3. 機能の削除や価格変更など、リポジトリから読み取れない方針の変更
- App Store Connect への入力そのもの（ブラウザ操作）はユーザーが行う。こちらは「画面の項目名 → 入力値」を metadata ファイルに揃え、コピーして貼れる状態にする
- 文言の正本は各アプリの `marketing/app-store-metadata.md`（なければ同等のドラフトを作成）。本参照は手順と判断、fields 参照は項目定義、metadata は貼る本文

## 関連ファイル（プロジェクト内の典型配置）

| 用途 | 場所（なければ同等を探す／作る） |
|------|------|
| App Store Connect に入力する文言の正本 | `marketing/app-store-metadata.md` |
| スクリーンショット用素材・エディタ | `marketing/screenshots/` など |
| サポート・プライバシーページ | Pages 用 submodule / 公開リポジトリ |
| バージョン番号 | `project.yml` の `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION`（または Info.plist 相当） |
| アップロード | `make upload ASC_KEY_PATH=... ASC_KEY_ID=... ASC_ISSUER_ID=...`（[Makefile テンプレート](../templates/Makefile)） |

## 提出フロー（初回・アップデート共通）

1. **変更内容の把握**: `git log` と README（機能説明）から前回提出以降の変更を洗い出す。ユーザー向けに意味のある変更（新機能・挙動変更・不具合修正）だけを拾い、内部実装の変更は除く
2. **バージョン番号**: `CURRENT_PROJECT_VERSION`（`CFBundleVersion`）を +1（本体・extension があるならすべて同じ値）。機能追加なら `MARKETING_VERSION` のマイナーを上げる。不具合修正のみならパッチ
3. **サポートページ**: FAQ・プライバシーポリシーに影響するなら更新（外部送信先の追加はプライバシーポリシー必須）。Pages の `main` は公開中アプリの状態に合わせる。未公開機能の説明は `develop` に置き、審査通過後に `main` へマージする
4. **metadata の更新**: `marketing/app-store-metadata.md` を [fields](app-store-connect-fields.md) の定義に沿って更新。アップデート時は「このバージョンの最新情報」を必ず書く
5. **スクリーンショットの要否**: 既存スライドのいずれかの画面に見た目の変更があれば、その画面だけ撮り直して再出力。なければ据え置き
6. **アップロード**: `make upload ASC_KEY_PATH=... ASC_KEY_ID=... ASC_ISSUER_ID=...`（API キーが必要。キーが無ければユーザーに確認）。`ITSAppUsesNonExemptEncryption: false` 済みなら輸出コンプライアンスの質問は出ない
7. **提出準備**: metadata の内容を項目名付きで揃え、ビルド選択・審査メモまでコピー可能な状態にする。再提出のときは冒頭に「Update since the last review:」で対応内容だけ書く
8. **公開後の確認リスト**: アップデート案内、Pages の `develop` → `main`、fields／metadata の変更履歴に提出日・バージョン・審査結果を追記（プロジェクトに履歴節があれば）

## 判断ルール（横断）

- **文言**: 機能の列挙ではなく、ユーザーが得る価値を書く。対象が明確なら先に言い切る。利用シーンを過度に限定する表現や比喩的な書き出しは使わない。結果の約束は避け、機能で言えることにする
- **価格表現**: スクリーンショット・見出し・ラベルに「無料」「割引」を入れない（Guideline 2.3.7）。価格に触れるのは概要文だけ
- **検索語**: 名前・サブタイトルに含まれる語はキーワード欄に入れない。部分一致しない語は効かせたい側（多くはサブタイトル）に置く
- **プライバシー**: ユーザーデータを外部に送る機能を追加したら「Appのプライバシー」「コンテンツ配信権」「プライバシーポリシー」「審査メモの External services」を全部見直す
- **アクセシビリティ**: 検証していない機能は申告しない
- **審査メモ**: 日本語でよい。権限の範囲・サインイン要否・データなしでも開ける画面・外部通信の範囲を必ず書く。プレースホルダ記法 `[ ]` は使わず実際の値を書く
- **著作権**: ユーザー指定または既存 metadata の表記に従う。本名や別アカウント名を勝手に使わない

## スクリーンショット

加工は [release-and-support.md](release-and-support.md) の「ストア用スクリーンショット」（[ParthJadhav/app-store-screenshots](https://github.com/ParthJadhav/app-store-screenshots)）。

- 見出しは結果の約束を避け、機能で言えることにする。価格表現を入れない
- 実機キャプチャは写真アプリの縮小コピーではなく原本（十分な解像度）を使う
- JSON を直接編集したら Export 前に必ずリロード（localStorage 先行描画のため）
- 出力確認はファイル更新時刻ではなく中身で判断する（zip 展開は元の時刻を引き継ぐ）
- この環境にブラウザが無いときは、書き出し PNG を Read で見て確認する

## 今後の方針の追記

提出・ストア関連で新しい方針を受けたら、該当する節と [fields](app-store-connect-fields.md) に反映する。
