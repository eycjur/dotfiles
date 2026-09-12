# 開発用コマンド（Mac上で実行する）
# コピーしたら MyApp / BUNDLE_ID を置き換える
PROJECT      = MyApp.xcodeproj
SCHEME       = MyApp
BUNDLE_ID    = com.kmuto.MyApp
TEAM_ID     ?= LFTR9WH44N
SIMULATOR   ?= iPhone Air
DEVICE_ID   ?= 00008140-00126D091A82801C
DESTINATION  = platform=iOS Simulator,name=$(SIMULATOR)
XCODE_APP   ?= /Applications/Xcode.app
export DEVELOPER_DIR = $(XCODE_APP)/Contents/Developer

BUILD_DIR    = build
ARCHIVE      = $(BUILD_DIR)/$(SCHEME).xcarchive
APP          = $(BUILD_DIR)/Build/Products/Debug-iphoneos/$(SCHEME).app
SIM_APP      = $(BUILD_DIR)/Build/Products/Debug-iphonesimulator/$(SCHEME).app
# make reinstall で退避するアプリのデータコンテナ（SwiftData・UserDefaults等）
APPDATA_DIR  = $(BUILD_DIR)/appdata
DEVICECTL_COPY = xcrun devicectl device copy $(1) --device $(DEVICE_ID) \
	--domain-type appDataContainer --domain-identifier $(BUNDLE_ID)

.PHONY: help setup generate open run reinstall run-sim archive upload test clean

help: ## コマンド一覧を表示
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-10s %s\n", $$1, $$2}'

setup: ## xcodegenをインストール（未インストール時のみ）
	test -d $(XCODE_APP) || (echo "Xcode.appが $(XCODE_APP) に見つかりません" >&2; exit 1)
	command -v xcodegen >/dev/null || brew install xcodegen

generate: ## Xcodeプロジェクトを生成
	xcodegen generate

open: generate ## プロジェクトを生成してXcodeで開く
	open -a $(XCODE_APP) $(PROJECT)

run: generate ## 実機へビルド・インストール・起動
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) \
		-destination 'platform=iOS,id=$(DEVICE_ID)' \
		-derivedDataPath $(BUILD_DIR) \
		-allowProvisioningUpdates build
	xcrun devicectl device install app --device $(DEVICE_ID) $(APP)
	xcrun devicectl device process launch --terminate-existing \
		--device $(DEVICE_ID) $(BUNDLE_ID)

# ストア申請用にデータを残したまま、権限情報を初期化する
reinstall: check-device generate ## 実機のアプリをデータ・設定を保ったまま削除・再インストールする
	rm -rf $(APPDATA_DIR)
	mkdir -p $(APPDATA_DIR)
	$(call DEVICECTL_COPY,from) --source Library --destination $(APPDATA_DIR)/Library
	$(call DEVICECTL_COPY,from) --source Documents --destination $(APPDATA_DIR)/Documents
	xcrun devicectl device uninstall app --device $(DEVICE_ID) $(BUNDLE_ID)
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) \
		-destination 'platform=iOS,id=$(DEVICE_ID)' \
		-derivedDataPath $(BUILD_DIR) \
		-allowProvisioningUpdates build
	xcrun devicectl device install app --device $(DEVICE_ID) $(APP)
	$(call DEVICECTL_COPY,to) --source $(APPDATA_DIR)/Library --destination Library
	$(call DEVICECTL_COPY,to) --source $(APPDATA_DIR)/Documents --destination Documents
	xcrun devicectl device process launch --device $(DEVICE_ID) $(BUNDLE_ID)

run-sim: generate ## シミュレータでビルド・インストール・起動（SIMULATOR="名前"で変更可）
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) \
		-destination '$(DESTINATION)' -derivedDataPath $(BUILD_DIR) build
	xcrun simctl boot "$(SIMULATOR)" 2>/dev/null || true
	open -a Simulator
	xcrun simctl install booted $(SIM_APP)
	xcrun simctl launch booted $(BUNDLE_ID)

archive: generate ## Releaseアーカイブを作成
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) \
		-configuration Release \
		-destination 'generic/platform=iOS' \
		-archivePath $(ARCHIVE) \
		-allowProvisioningUpdates \
		archive

upload: ## TestFlightへアップロード（要 有料メンバーシップ + ASC APIキー）
	@test -n "$(ASC_KEY_PATH)" && test -n "$(ASC_KEY_ID)" && test -n "$(ASC_ISSUER_ID)" || \
		(echo "ASC_KEY_PATH / ASC_KEY_ID / ASC_ISSUER_ID を指定してください" >&2; exit 1)
	$(MAKE) archive
	mkdir -p $(BUILD_DIR)
	sed 's/TEAM_ID_PLACEHOLDER/$(TEAM_ID)/' ExportOptions.template.plist \
		> $(BUILD_DIR)/ExportOptions.plist
	xcodebuild -exportArchive \
		-archivePath $(ARCHIVE) \
		-exportOptionsPlist $(BUILD_DIR)/ExportOptions.plist \
		-allowProvisioningUpdates \
		-authenticationKeyPath $(ASC_KEY_PATH) \
		-authenticationKeyID $(ASC_KEY_ID) \
		-authenticationKeyIssuerID $(ASC_ISSUER_ID)

test: ## コアロジックのみSwiftPMでテスト（Xcode不要。Linuxでも動く）
	swift test

clean: ## 生成物を削除
	rm -rf $(PROJECT) .build $(BUILD_DIR)
