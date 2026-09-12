# ビルド・署名・実機確認

依頼に関係する項目だけを使う。以下の識別子・構成は個人環境の既定値であり、既存プロジェクトやユーザーの指定を優先する。

## プロジェクト生成（XcodeGen + Makefile）

新規プロジェクトで生成方式の指定がなければ、`.xcodeproj` をgit管理せず、`project.yml` から XcodeGen で生成する運用を推奨する。既存プロジェクトはその管理方式に従う。
差分レビューが容易になり、pbxprojのコンフリクトがなくなる。

- `.gitignore` に `*.xcodeproj` / `xcuserdata/` / `DerivedData/` / `.build/` / `build/` を追加
- 定型コマンドは [Makefile テンプレート](../templates/Makefile) をコピーし、`MyApp` と `BUNDLE_ID` を置き換える。実機は `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun devicectl list devices` で物理デバイスの ID を確認し、`make run DEVICE_ID=<ID>` のように渡す。複数台ある場合は対象を特定する
- テンプレートのターゲット: `setup` / `generate` / `open` / `run` / `reinstall` / `run-sim` / `test` / `clean`
- `open` / `run` / `reinstall` / `run-sim` は `generate` に依存させる。`xcodegen generate` は冪等で速いため毎回実行してよい
- 複数Xcodeがある環境向けに `export DEVELOPER_DIR = $(XCODE_APP)/Contents/Developer` をMakefileで固定
- **実機で権限ダイアログの再表示を確認する**場合は、削除・再インストールを検討する。権限種別や OS によって状態の保持が異なるため、初期化できたかを実機で確認する。`make reinstall` でデータコンテナ（`Library` / `Documents`）を退避→アンインストール→ビルド＆インストール→復元→起動する。アプリデータ（SwiftData等）と設定（UserDefaults）はコンテナ内なので残り、権限の再表示は復元後に確認する。通知許可はOSがしばらく記憶することがあるので、出ないときは端末を再起動する
- Xcode Cloud利用時は `ci_scripts/ci_post_clone.sh` でクローン直後に生成:

```sh
#!/bin/sh
set -e
brew install xcodegen
cd "$CI_PRIMARY_REPOSITORY_PATH"
xcodegen generate
```

## 署名・Team ID・Bundle ID

`project.yml` の settings に記述する:

```yaml
options:
  bundleIdPrefix: com.kmuto          # → PRODUCT_BUNDLE_IDENTIFIER = com.kmuto.<TargetName>。個人環境の既定値
settings:
  base:
    DEVELOPMENT_TEAM: LFTR9WH44N     # ユーザー（kmuto）のTeam ID。個人環境の既定値
    CODE_SIGN_STYLE: Automatic
```

- Team IDは全ターゲット（本体・Widget等のextension・テスト以外の実行物）に同じ値を設定する
- extensionのBundle IDは本体のサフィックスにする（例: `com.kmuto.MyApp.MyWidget`）— これを守らないと埋め込み検証で弾かれる
- App Group等のCapabilityは entitlements ファイルに記述し、自動署名に任せると初回ビルド時にDeveloperポータルへ自動登録される
- App Group IDは `group.<本体Bundle ID>` の形式（アプリ・extension両方のentitlementsに同じIDを列挙）

## バージョン番号の運用

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

## デバッガなしで実機実行

ベータ OS の実機で起動前の黒画面や pre-main クラッシュが起きた場合、デバッガ接続の影響を切り分けるため、一時的に次の設定を試す:

```yaml
schemes:
  MyApp:
    run:
      debugEnabled: false   # XcodeのGUIでは Edit Scheme > Run > Debug executable のチェックを外すのと同じ
```

問題が再現しなければ通常のデバッガ設定を維持する。デバッガなしの運用を依頼されている場合はその指定を優先する。

## テスト構成

- 発火時刻計算・バージョン比較などの純粋ロジックを Xcode なしでもテストしたい場合は、Foundation のみに依存するファイルに分離し、`Package.swift` を併設する。既存のテスト構成で十分なら増やさない
- テストは `make test`（`swift test`）で実行する — Xcodeがない環境（Linux CI含む）でも回る
