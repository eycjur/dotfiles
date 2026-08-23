---
name: ios-app-setup
description: iOSアプリ開発時に必要な標準設定・仕組みのチェックリストとテンプレート集。新規iOSアプリの立ち上げ、署名・Team ID設定、バージョン番号運用、デバッガなし実機実行、起動時のアップデート確認、サポート窓口・不具合報告、ログ・診断情報、App Store提出準備のいずれかに取り組むときに使用する。
---

# iOSアプリ開発 標準設定チェックリスト

新規iOSアプリの立ち上げや、既存アプリへの標準機能追加時に確認する項目集。

## 1. プロジェクト生成（XcodeGen + Makefile）

`.xcodeproj` はgit管理せず、`project.yml` から XcodeGen で生成する運用にする。
差分レビューが容易になり、pbxprojのコンフリクトがなくなる。

- `.gitignore` に `*.xcodeproj` / `xcuserdata/` / `DerivedData/` / `.build/` を追加
- Makefile に定型コマンドをまとめる:
  - `make setup` — xcodegen未インストール時のみ `brew install xcodegen`
  - `make generate` — `xcodegen generate`
  - `make open` — generate してから `open -a /Applications/Xcode.app <project>`
  - `make run` — 実機向けにビルドし、インストールして起動する単一コマンド: `xcodebuild -project ... -scheme ... -destination 'platform=iOS,id=$(DEVICE_ID)' -derivedDataPath build build` → `xcrun devicectl device install app --device $(DEVICE_ID) build/Build/Products/Debug-iphoneos/<App>.app` → `xcrun devicectl device process launch --terminate-existing --device $(DEVICE_ID) <Bundle ID>`（`.app` のパスを固定するため `-derivedDataPath build` を指定する。`build/` はgitignoreに追加）
  - `make run-sim` — シミュレータ向けにビルドし、インストールして起動する単一コマンド: `xcodebuild ... -destination 'platform=iOS Simulator,name=$(SIMULATOR)' -derivedDataPath build build` → `xcrun simctl boot "$(SIMULATOR)"` → `open -a Simulator` → `xcrun simctl install booted build/Build/Products/Debug-iphonesimulator/<App>.app` → `xcrun simctl launch booted <Bundle ID>`（`SIMULATOR ?= iPhone Air` を既定にする（App Storeスクリーンショット撮影用）。`make run-sim SIMULATOR="iPhone 17 Pro"` で一時変更可）。ビルドのみの`build`/`build-sim`ターゲットは分けず`run`/`run-sim`に統合し、コマンド数を絞る
  - `make test` / `make test-spm` / `make clean`（cleanでは `-derivedDataPath` の出力先も削除する）
  - `open` / `run` / `run-sim` / `test` は `generate` に依存させる（`run: generate` のように書く）。`project.yml` の変更が常に反映され、`xcodegen generate` は冪等で速いため毎回実行してよい
- Makefile冒頭の変数:
  - `DEVICE_ID ?= 00008140-00126D091A82801C` — ユーザー（kmuto）のiPhoneのUDID。新規アプリでもこの値をそのまま使う
- 複数Xcodeがある環境向けに `export DEVELOPER_DIR = $(XCODE_APP)/Contents/Developer` をMakefileで固定
- Xcode Cloud利用時は `ci_scripts/ci_post_clone.sh` でクローン直後に生成:

```sh
#!/bin/sh
set -e
brew install xcodegen
cd "$CI_PRIMARY_REPOSITORY_PATH"
xcodegen generate
```

## 2. 署名・Team ID・Bundle ID

`project.yml` の settings に記述する:

```yaml
options:
  bundleIdPrefix: com.kmuto          # → PRODUCT_BUNDLE_IDENTIFIER = com.kmuto.<TargetName>。新規アプリでもこの値をそのまま使う
settings:
  base:
    DEVELOPMENT_TEAM: LFTR9WH44N     # ユーザー（kmuto）のTeam ID。新規アプリでもこの値をそのまま使う
    CODE_SIGN_STYLE: Automatic
```

- Team IDは全ターゲット（本体・Widget等のextension・テスト以外の実行物）に同じ値を設定する
- extensionのBundle IDは本体のサフィックスにする（例: `com.kmuto.MyApp.MyWidget`）— これを守らないと埋め込み検証で弾かれる
- App Group等のCapabilityは entitlements ファイルに記述し、自動署名に任せると初回ビルド時にDeveloperポータルへ自動登録される
- App Group IDは `group.<本体Bundle ID>` の形式（アプリ・extension両方のentitlementsに同じIDを列挙）

## 3. バージョン番号の運用

- `CFBundleShortVersionString`（マーケティングバージョン、例 "1.0"）と `CFBundleVersion`（ビルド番号）を分けて管理
- **App Store Connectへアップロードするたびに `CFBundleVersion` を+1する**（同じ番号は重複エラーで拒否される）
- **extensionのバージョンは本体と完全一致させる**（不一致はApp Store検証で警告）
- デバッグビルドと公開ビルドを見分けるため、表示用バージョンにビルド種別を埋め込む:

```swift
enum AppVersion {
    static var marketing: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-"
    }
    static var display: String {
        #if DEBUG
        "\(marketing) (beta\(betaBuildNumber ?? "?"))"
        #else
        marketing
        #endif
    }
}
```

- 手元ビルドの通し番号は、postCompileScript でカウンタファイル（gitignore済み）を+1し、成果物バンドルへ `beta-build.txt` として埋め込む（スクリプトがビルド成果物へ書き込むため `ENABLE_USER_SCRIPT_SANDBOXING: NO` が必要）

## 4. デバッガなしで実機実行

スキーム定義では必ずデバッガを外して起動する設定にする（ベータOSの実機ではデバッガ接続が不安定で、起動前の長い黒画面・pre-mainクラッシュの原因になるため）:

```yaml
schemes:
  MyApp:
    run:
      debugEnabled: false   # XcodeのGUIでは Edit Scheme > Run > Debug executable のチェックを外すのと同じ
```

デバッグしたいときだけ true に戻すか、Xcode側で一時的にスキームを編集する。

## 5. 起動時のアップデート確認

iTunes Lookup API で公開中バージョンを取得し、現行より新しければ控えめに案内する。

- エンドポイント: `https://itunes.apple.com/lookup?id=<AppStoreのアプリID>&country=jp`（レスポンスの `results[0].version` を使う）
- App StoreのアプリIDはApp Store Connectの「アプリ情報」で確認（URL `apps.apple.com/app/id<ID>` の数字）
- **公開直後は最大24時間ほど古い値が返る**ことを許容する設計にする
- オフライン・API不調は正常系として黙って無視する（エラー表示もログも不要）
- バージョン比較は文字列比較でなく数値の列として比較する（"1.10" > "1.9" を正しく判定。純粋ロジックなのでユニットテスト対象にする）

## 6. サポート・不具合報告

- **サポートページとプライバシーポリシーはApp Store提出に必須**。本体リポジトリがprivateでも、公開用リポジトリ＋GitHub Pagesで無料公開できる（本体リポジトリからはsubmoduleとして参照すると管理しやすい）
- 公開用リポジトリはGitHubの `eycjur` アカウントに `<アプリ名>-pages` の命名で作り、`https://eycjur.github.io/<アプリ名>-pages/` で公開する。ページの構成・内容は https://github.com/eycjur/infinite-alarm-pages を参考にする
- アプリの対応言語（「9. ローカライズ」参照）に合わせ、日本語＋英語の場合は `/ja/support.html` `/en/support.html` のようにディレクトリを分け、アプリからは `Bundle.main.preferredLocalizations.first` で振り分ける
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

## 7. ログ・診断情報

ユーザーからの不具合報告を調査可能にする仕組み:

- `os.Logger`（Xcodeコンソール用）と書き出し用ファイル（Documents配下）の**二重出力**にする
- ファイルはサイズ上限（例: 512KB）を超えたら後半（新しい側）だけ残す簡易ローテーション。行の途中で切れないよう最初の改行までは捨てる
- タイムスタンプは**UTCでなく端末のローカル時刻**にする（「朝7時に鳴らなかった」等のユーザー報告と突き合わせるため）
- 複数Taskからの書き込みに備え、専用 `DispatchQueue` で直列化
- ログ書き込みの失敗でアプリ動作を妨げない（コンソールにのみ残して握り潰す）
- 起動時に「アプリ起動 vX.X iOSXX」を記録する（その時刻にアプリを開いていたかが調査の手がかりになる）
- 診断情報エクスポートは「環境情報（アプリ・OSバージョン、権限状態）＋アプリ内の設定内容＋OS側の実状態＋操作ログ」を1テキストにまとめる。**ユーザー自由入力（ラベル等）は伏せ字にする**（Issueは公開されるため）

## 8. Info.plist・App Store提出の要点

- `GENERATE_INFOPLIST_FILE: false` にして Info.plist を明示管理（XcodeGenの `info.properties` で上書き）
- 使用する機能の UsageDescription を必ず書く（例: `NSAlarmKitUsageDescription`）。日本語＋英語対応の場合、ローカライズは `InfoPlist.xcstrings` で行う（アプリ名 `CFBundleDisplayName` もここで対応）
- `ITSAppUsesNonExemptEncryption: false` — OS標準の暗号化のみなら、提出ごとの輸出コンプライアンス質問をスキップできる
- `LSApplicationCategoryType` を設定（例: `public.app-category.utilities`）
- `UILaunchScreen` に `UIColorName`（Assets のカラー）＋ `UIImageName` を指定し、起動中の無地画面（ダークモードだと真っ黒）を避ける
- 対応方向を絞るなら `UISupportedInterfaceOrientations`、iPhone専用なら `TARGETED_DEVICE_FAMILY: "1"`
- App Store Connectのメタデータ（アプリ名30字/サブタイトル30字/プロモ170字/説明4000字/キーワード100字）は `marketing/app-store-metadata.md` のようにリポジトリでドラフト管理する。キーワード欄にアプリ名・サブタイトル内の語を入れても重複インデックスされない

## 9. ローカライズ

- 対応言語は「日本語のみ」か「日本語＋英語」のどちらかにする。海外でも利用可能な内容なら日本語＋英語、国内利用が前提の内容（日本固有のサービス・制度に依存する等）なら日本語のみと判断してよい。判断がつかない場合はユーザーに確認する
- 日本語のみの場合: `developmentLanguage: ja` にし、文字列は日本語を直接書く（String Catalogは不要）
- 日本語＋英語の場合: `developmentLanguage: en` にする（それ以外の環境では英語にフォールバック）。コード内の日本語文字列をキーとして、ja/en両方の訳をString Catalogに明示的に持つ
- UI文字列は `Localizable.xcstrings`、Info.plist系は `InfoPlist.xcstrings` の String Catalog で管理
- アプリ内に言語切り替えは実装せず、`UIApplication.openSettingsURLString` でiOSのアプリ別言語設定へ誘導するのが簡単

## 10. テスト構成

- 発火時刻計算・バージョン比較などの**純粋ロジックはFoundationのみに依存するファイルに分離**し、`Package.swift` を併設して SwiftPM（`swift test`）でも実行可能にする — Xcodeがない環境（Linux CI含む）でテストが回る
- Xcode側のユニットテストは `make test`（`xcodebuild ... test`）で実行
