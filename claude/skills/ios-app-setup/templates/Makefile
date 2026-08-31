# 開発用コマンド（Mac上で実行する）
# コピーしたら MyApp / BUNDLE_ID を置き換える
PROJECT      = MyApp.xcodeproj
SCHEME       = MyApp
BUNDLE_ID    = com.kmuto.MyApp
SIMULATOR   ?= iPhone Air
DEVICE_ID   ?= 00008140-00126D091A82801C
DESTINATION  = platform=iOS Simulator,name=$(SIMULATOR)
XCODE_APP   ?= /Applications/Xcode.app
export DEVELOPER_DIR = $(XCODE_APP)/Contents/Developer

BUILD_DIR    = build
APP          = $(BUILD_DIR)/Build/Products/Debug-iphoneos/$(SCHEME).app
SIM_APP      = $(BUILD_DIR)/Build/Products/Debug-iphonesimulator/$(SCHEME).app

.PHONY: help setup generate open run run-sim test test-spm clean

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

run-sim: generate ## シミュレータでビルド・インストール・起動（SIMULATOR="名前"で変更可）
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) \
		-destination '$(DESTINATION)' -derivedDataPath $(BUILD_DIR) build
	xcrun simctl boot "$(SIMULATOR)" 2>/dev/null || true
	open -a Simulator
	xcrun simctl install booted $(SIM_APP)
	xcrun simctl launch booted $(BUNDLE_ID)

test: generate ## ユニットテストを実行（シミュレータ）
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -destination '$(DESTINATION)' test

test-spm: ## コアロジックのみSwiftPMでテスト（Xcode不要。Linuxでも動く）
	swift test

clean: ## 生成物を削除
	rm -rf $(PROJECT) .build $(BUILD_DIR)
