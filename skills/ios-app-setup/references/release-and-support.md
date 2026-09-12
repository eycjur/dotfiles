# 公開・サポート・診断

機能追加や提出準備で必要な項目だけを使う。ストアの提出要件・API の挙動・文字数制限は作業時の公式資料で確認する。公開先の作成・更新は依頼や既存の承認範囲で実施する。

## 起動時のアップデート確認

iTunes Lookup API で公開中バージョンを取得し、現行より新しければ控えめに案内する。

- エンドポイント: `https://itunes.apple.com/lookup?id=<AppStoreのアプリID>&country=jp`（レスポンスの `results[0].version` を使う）
- App StoreのアプリIDはApp Store Connectの「アプリ情報」で確認（URL `apps.apple.com/app/id<ID>` の数字）
- **公開直後は最大24時間ほど古い値が返る**ことを許容する設計にする
- オフライン・API 不調で起動を妨げたりエラーダイアログを出したりしない。失敗は既存の診断ログへ残し、更新なしとは区別する
- バージョン比較は文字列比較でなく数値の列として比較する（"1.10" > "1.9" を正しく判定。純粋ロジックなのでユニットテスト対象にする）

## サポート・不具合報告

- **サポートページとプライバシーポリシーはApp Store提出に必須**。本体リポジトリがprivateでも、公開用リポジトリ＋GitHub Pagesで無料公開できる（本体リポジトリからはsubmoduleとして参照すると管理しやすい）
- 公開用リポジトリはGitHubの `eycjur` アカウントに `<アプリ名>-pages` の命名で作り、`https://eycjur.github.io/<アプリ名>-pages/` で公開する。ページの構成・内容は https://github.com/eycjur/infinite-alarm-pages を参考にする
- ブランチ運用: GitHub Pagesは `main` から公開されるため、**`main` は常にApp Storeで公開中のアプリの状態と一致させる**。未リリース版に向けたページ更新は `develop` ブランチで進め、アプリのアップデートが公開されたタイミングで `main` にマージする（審査中の機能説明が先にページへ出てしまうのを防ぐ）
- アプリの対応言語（「ローカライズ」参照）に合わせ、日本語＋英語の場合は `/ja/support.html` `/en/support.html` のようにディレクトリを分け、アプリからは `Bundle.main.preferredLocalizations.first` で振り分ける
- 問い合わせ窓口は公開リポジトリのGitHub Issuesで足りる。Issueテンプレート（`bug_report.yml` / `feature_request.yml`）を用意し、アプリからはクエリパラメータで環境情報をプリセットしたURLを開く:

```swift
var components = URLComponents(string: "https://github.com/eycjur/<アプリ名>-pages/issues/new")!
components.queryItems = [
    URLQueryItem(name: "template", value: "bug_report.yml"),
    URLQueryItem(name: "ios-version", value: "iOS \(UIDevice.current.systemVersion)"),
    URLQueryItem(name: "app-version", value: AppVersion.display),
]
```

- 「このアプリについて」画面に置くもの: バージョン＋iOSバージョン表示、アップデート案内、サポート・プライバシーポリシーへのリンク、不具合報告・機能要望ボタン、診断情報の書き出し（ShareLink）、言語変更（`UIApplication.openSettingsURLString` でiOSのアプリ別言語設定へ誘導）

## ログ・診断情報

ユーザーからの不具合報告を調査可能にする仕組み:

- `os.Logger`（Xcodeコンソール用）と書き出し用ファイル（Documents配下）の**二重出力**にする
- ファイルはサイズ上限（例: 512KB）を超えたら後半（新しい側）だけ残す簡易ローテーション。行の途中で切れないよう最初の改行までは捨てる
- タイムスタンプは**UTCでなく端末のローカル時刻**にする（「朝7時に鳴らなかった」等のユーザー報告と突き合わせるため）
- 複数Taskからの書き込みに備え、専用 `DispatchQueue` で直列化
- ログ書き込みの失敗でアプリ動作を妨げない（コンソールにのみ残して握り潰す）
- 起動時に「アプリ起動 vX.X iOSXX」を記録する（その時刻にアプリを開いていたかが調査の手がかりになる）
- 診断情報エクスポートは「環境情報（アプリ・OSバージョン、権限状態）＋アプリ内の設定内容＋OS側の実状態＋操作ログ」を1テキストにまとめる。**ユーザー自由入力（ラベル等）は伏せ字にする**（Issueは公開されるため）

## Info.plist・App Store提出の要点

- `GENERATE_INFOPLIST_FILE: false` にして Info.plist を明示管理（XcodeGenの `info.properties` で上書き）
- 使用する機能の UsageDescription を必ず書く（例: `NSAlarmKitUsageDescription`）。日本語＋英語対応の場合、ローカライズは `InfoPlist.xcstrings` で行う（アプリ名 `CFBundleDisplayName` もここで対応）
- `ITSAppUsesNonExemptEncryption: false` — OS標準の暗号化のみなら、提出ごとの輸出コンプライアンス質問をスキップできる
- `LSApplicationCategoryType` を設定（例: `public.app-category.utilities`）
- `UILaunchScreen` に `UIColorName`（Assets のカラー）＋ `UIImageName` を指定し、起動中の無地画面（ダークモードだと真っ黒）を避ける
- 対応方向を絞るなら `UISupportedInterfaceOrientations`、iPhone専用なら `TARGETED_DEVICE_FAMILY: "1"`
- App Store Connectのメタデータ（アプリ名30字/サブタイトル30字/プロモ170字/説明4000字/キーワード100字）は `marketing/app-store-metadata.md` のようにリポジトリでドラフト管理する。キーワード欄にアプリ名・サブタイトル内の語を入れても重複インデックスされない
- **提出の自律実行・判断ルール**は [app-store-connect.md](app-store-connect.md)、**全項目の一覧と決め方**は [app-store-connect-fields.md](app-store-connect-fields.md) を読む
- **ストア用スクリーンショットの加工**は [ParthJadhav/app-store-screenshots](https://github.com/ParthJadhav/app-store-screenshots) を使う（`npx skills add ParthJadhav/app-store-screenshots` でエージェント用スキルを入れ、シミュレータ等の生キャプチャからストア向けスライドを作る）。方針は [app-store-connect.md](app-store-connect.md) の「スクリーンショット」節

## ローカライズ

- 対応言語は「日本語のみ」か「日本語＋英語」のどちらかにする。海外でも利用可能な内容なら日本語＋英語、国内利用が前提の内容（日本固有のサービス・制度に依存する等）なら日本語のみと判断してよい。判断がつかない場合はユーザーに確認する
- 日本語のみの場合: `developmentLanguage: ja` にし、文字列は日本語を直接書く（String Catalogは不要）
- 日本語＋英語の場合: `developmentLanguage: en` にする（それ以外の環境では英語にフォールバック）。コード内の日本語文字列をキーとして、ja/en両方の訳をString Catalogに明示的に持つ
- UI文字列は `Localizable.xcstrings`、Info.plist系は `InfoPlist.xcstrings` の String Catalog で管理
- アプリ内に言語切り替えは実装せず、`UIApplication.openSettingsURLString` でiOSのアプリ別言語設定へ誘導するのが簡単

