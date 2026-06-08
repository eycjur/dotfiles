# 基本的にzshを利用するが、makefileなどで利用するための最低限の設定

source ~/shell/env.sh

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path bash)"

source ~/shell/alias.sh

case ${OSTYPE} in
    darwin*)
        source ~/shell/platform/mac.sh
        ;;
    linux*)
        case ${WSL_DISTRO_NAME} in
            Ubuntu)
                source ~/shell/platform/wsl.sh
                ;;
            *)
                source ~/shell/platform/linux.sh
                ;;
        esac
        ;;
esac
