# App Store Connect 入力・提出

「ストアに出したい」「アップデートを提出したい」「審査に落ちた」ときに使う。
各項目の定義・決め方は [app-store-connect-fields.md](app-store-connect-fields.md) を正本とする。画面に新しい項目が現れたら、まずそこに追記してから値を決める。

審査の正本は公式の [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)（[日本語](https://developer.apple.com/jp/app-store/review/guidelines/)）。スキル内の要約は既知の指摘のメモであり、条文の代わりにしない。

## 自律実行の原則

- ユーザーから追加情報がなくても、リポジトリ（README・コード・既存の `marketing/app-store-metadata.md`・git log）と ASC の現行値・本スキルの判断ルールから入力値を決め、提出直前まで進める
- ユーザーに確認するのは次だけ。それ以外は決めて報告する
  1. App Store Connect API キー（`ASC_KEY_PATH` / `ASC_KEY_ID` / `ASC_ISSUER_ID`）が環境にないとき
  2. 審査添付に使う実機の画面録画ファイル（こちらでは撮れない。`UIBackgroundModes` があるならバックグラウンド実演を含む）
  3. 機能の削除や価格変更など、リポジトリから読み取れない方針の変更
  4. ASC へ書き込む文面の差分確認と、最終的な提出確定（`submit`）の実行可否
- `asc` CLI が使える場合は、文面反映・録画添付・ビルド紐付け・`asc validate` まで公式 API 経由で実行する（コマンドと手順は [asc-cli.md](asc-cli.md)）。Resolution Center 返信・App のプライバシー・規制関連の申告など API 非対応の項目だけブラウザ操作用に `marketing/app-store-metadata.md` へ揃える
- 更新・再提出では ASC の現行値を基準にして差分更新し、反映後に同じ本文を `marketing/app-store-metadata.md` へ書き戻す。本参照は手順と判断、fields 参照は項目定義、metadata はリポジトリ側の控え・下書きとする

## 関連ファイル（プロジェクト内の典型配置）

| 用途 | 場所（なければ同等を探す／作る） |
|------|------|
| App Store Connect 入力文言の下書き・控え | `marketing/app-store-metadata.md` |
| スクリーンショット用素材・エディタ | `marketing/screenshots/` など |
| サポート・プライバシーページ | Pages 用 submodule / 公開リポジトリ |
| バージョン番号 | `project.yml` の `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION`（または Info.plist 相当） |
| アップロード | `make upload ASC_KEY_PATH=... ASC_KEY_ID=... ASC_ISSUER_ID=...`（[Makefile テンプレート](../templates/Makefile)） |

## 提出フロー（初回・アップデート共通）

1. **変更内容の把握**: `git log` と README（機能説明）から前回提出以降の変更を洗い出す。ユーザー向けに意味のある変更（新機能・挙動変更・不具合修正）だけを拾い、内部実装の変更は除く
2. **バージョン番号**: `CURRENT_PROJECT_VERSION`（`CFBundleVersion`）を +1（本体・extension があるならすべて同じ値）。機能追加なら `MARKETING_VERSION` のマイナーを上げる。不具合修正のみならパッチ
3. **サポートページ**: FAQ・プライバシーポリシーに影響するなら更新（外部送信先の追加はプライバシーポリシー必須）。Pages の `main` は公開中アプリの状態に合わせる。未公開機能の説明は `develop` に置き、審査通過後に `main` へマージする
4. **文面・metadata の作成**: 更新・再提出ではまず `asc` で ASC の現行値を読み出して土台にする。初回はリポジトリと [fields](app-store-connect-fields.md) の定義から作成する。アップデート時は「このバージョンの最新情報」を必ず書く
5. **スクリーンショットの要否**: 既存スライドのいずれかの画面に見た目の変更があれば、その画面だけ撮り直して再出力。なければ据え置き
6. **アップロードとビルド紐付け**: `make upload ASC_KEY_PATH=... ASC_KEY_ID=... ASC_ISSUER_ID=...` で上げ、`asc builds list` で `VALID` になってから `asc versions attach-build` でバージョンへ紐付ける。`ITSAppUsesNonExemptEncryption: false` 済みなら輸出コンプライアンスの質問は出ない
7. **ガイドライン照合（セルフレビュー）**: 提出準備の前に必ず行う。[App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)（[日本語](https://developer.apple.com/jp/app-store/review/guidelines/)）の現行文を読み、今回の差分・metadata・権限画面・`UIBackgroundModes`・スクリーンショットを照合する。スキル内の要約や過去の指摘だけで済ませない。既知の項目は [fields](app-store-connect-fields.md) の「審査で指摘されやすい点」も見る。項目ごとに「該当なし／対応済み／要確認」で報告し、問題があれば直してから次へ進む
8. **ASC 反映と提出前確認**: 書き込む文面の差分をユーザーへ提示してから `asc` で反映（概要・審査メモ・録画添付など）し、読み戻して一致を確認する。同じ本文を `marketing/app-store-metadata.md` にも書き戻し、`asc validate` を通して提出確定（`submit`）の直前でユーザー確認を取る。再提出のときは審査メモ冒頭に「Update since the last review:」で指摘ごとの対応とバイナリ変更の有無を書く。API 非対応項目はブラウザ入力用に一覧化する
9. **公開後の確認リスト**: アップデート案内、Pages の `develop` → `main`、fields／metadata の変更履歴に提出日・バージョン・審査結果を追記（プロジェクトに履歴節があれば）

## 判断ルール（横断）

- **文言**: 機能の列挙ではなく、ユーザーが得る価値を書く。対象が明確なら先に言い切る。利用シーンを過度に限定する表現や比喩的な書き出しは使わない。結果の約束は避け、機能で言えることにする
- **価格表現**: スクリーンショット・見出し・ラベルに「無料」「割引」を入れない（[Guideline 2.3.7](https://developer.apple.com/app-store/review/guidelines/#2.3.7)）。価格に触れるのは概要文だけ
- **検索語**: 名前・サブタイトルに含まれる語はキーワード欄に入れない。部分一致しない語は効かせたい側（多くはサブタイトル）に置く
- **プライバシー**: ユーザーデータを外部に送る機能を追加したら「Appのプライバシー」「コンテンツ配信権」「プライバシーポリシー」「審査メモの External services」を全部見直す
- **アクセシビリティ**: 検証していない機能は申告しない
- **審査メモ**: 日本語でよい。権限の範囲・サインイン要否・データなしでも開ける画面・外部通信の範囲を必ず書く。プレースホルダ記法 `[ ]` は使わず実際の値を書く。イヤホン限定など環境依存の条件は冒頭に条件と再現手順を書く。再提出時は「Update since the last review:」で指摘ごととバイナリ変更の有無
- **権限の事前説明**: ボタンは「次へ」「続ける」。同意を代行する語は [Guideline 5.1.1(iv)](https://developer.apple.com/app-store/review/guidelines/#5.1.1) で却下される。実装の文言は [release-and-support.md](release-and-support.md)
- **バックグラウンドモード**: 宣言した値ごとに実演根拠が必要。録画は「機能を起動 → ホーム画面に戻る（またはロック） → 動作が続く」（[Guideline 2.5.4](https://developer.apple.com/app-store/review/guidelines/#2.5.4)）
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
