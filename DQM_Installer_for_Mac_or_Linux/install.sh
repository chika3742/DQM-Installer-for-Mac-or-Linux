#!/usr/bin/env bash

echo

# デバッグ用
# PREMISE_PATH="$1"
# BODY_PATH="$2"
# BGM_PATH="$3"
# FORGE_PATH="$4"
# LIB_PATH="$5"
# SKIN_PATH="$6"
# DISPLAY_NAME="$7"

echo "---DQM Installer for Mac/Linux v1.0.0---"
echo
echo "※MacOSでの動作確認は出来ておりません。ご了承ください。"
echo "(Command+CまたはCtrl+Cで中断できます。)"
echo

echo "DQM 前提MODのパスを入力してください。"
read PREMISE_PATH
PREMISE_PATH=$(echo $PREMISE_PATH | tr -d "'")
echo
echo "DQM 本体MODのパスを入力してください。"
read BODY_PATH
BODY_PATH=$(echo $BODY_PATH | tr -d "'")
echo
echo "DQM 音声・BGMのパスを入力してください。"
read BGM_PATH
BGM_PATH=$(echo $BGM_PATH | tr -d "'")
echo
echo "Forgeのパスを入力してください。"
read FORGE_PATH
FORGE_PATH=$(echo $FORGE_PATH | tr -d "'")
echo
echo "libファイルのパスを入力してください。"
read LIB_PATH
LIB_PATH=$(echo $LIB_PATH | tr -d "'")
echo
echo "スキンPNGファイルのパスを入力してください。(何も入力せずEnterを押すと、デフォルトのスティーブになります。)"
read SKIN_PATH
SKIN_PATH=$(echo $SKIN_PATH | tr -d "'")
echo "バージョン表示名を入力してください。(何も入力せずEnterを押すと、「DQMV」になります。)"
read DISPLAY_NAME
echo

echo "前提MODのパス: $PREMISE_PATH"
echo "本体MODのパス: $BODY_PATH"
echo "DQM 音声・BGMのパス: $BGM_PATH"
echo "Forgeのパス: $FORGE_PATH"
echo "Forge libファイルのパス: $LIB_PATH"
SCRIPT_PATH=$(cd $(dirname $0); pwd)
if [ -z "$SKIN_PATH" ]; then
  SKIN_PATH="$SCRIPT_PATH/assets/steve.png"
  echo "スキンのパス(デフォルト): $SKIN_PATH"
else
  echo "スキンのパス: $SKIN_PATH"
fi
if [ -z "$DISPLAY_NAME" ]; then
  DISPLAY_NAME="DQMV"
  echo "バージョン/プロファイル表示名(デフォルト): $DISPLAY_NAME"
else
  echo "バージョン/プロファイル表示名: $DISPLAY_NAME"
fi
echo
echo "インストールを開始しますか？(y/N)"
read CONTINUE

case $CONTINUE in
  [Yy]* )
    echo "Yes"
    ;;
  * )
    echo "中断しました。"
    return 2>&- || exit
esac

echo "ファイルの存在をチェックしています。"
ERR=0
if [ ! -f "$PREMISE_PATH" ]; then
  echo "[ERROR] 前提MODファイル \"$PREMISE_PATH\" は存在しません。"
  ERR=1
fi
if [ ! -f "$BODY_PATH" ]; then
  echo "[ERROR] 本体MODファイル \"$BODY_PATH\" は存在しません。"
  ERR=1
fi
if [ ! -f "$BGM_PATH" ]; then
  echo "[ERROR] BGMファイル \"$BGM_PATH\" は存在しません。"
  ERR=1
fi
if [ ! -f "$FORGE_PATH" ]; then
  echo "[ERROR] Forgeファイル \"$FORGE_PATH\" は存在しません。"
  ERR=1
fi
if [ ! -f "$LIB_PATH" ]; then
  echo "[ERROR] libファイル \"$LIB_PATH\" は存在しません。"
  ERR=1
fi
if [ ! -f "$SKIN_PATH" ]; then
  echo "[ERROR] スキンファイル \"$SKIN_PATH\" は存在しません。"
  ERR=1
fi

if [ "$ERR" -eq "1" ]; then
  echo "[INFO] 中断しました。"
  return 2>&- || exit
fi

echo

if [ "$(expr substr $(uname -s) 1 5)" = 'Linux' ]; then
  MINECRAFT_DIR="/home/$(whoami)/.minecraft"
  OS="Linux"
elif [ "$(uname)" = 'Darwin' ]; then
  MINECRAFT_DIR="/Users/$(whoami)/Library/Application Support/minecraft"
  OS="MacOS"
fi

echo "Minecraft データフォルダ: $MINECRAFT_DIR"

echo
if [ ! -f "$MINECRAFT_DIR/versions/1.5.2/1.5.2.jar" ]; then
  echo "[ERROR] Minecraft 1.5.2の実行ファイルが見つかりません。動画を見ながらやり直してください。"
  return 2>&- || exit
fi

JAR_PATH="$MINECRAFT_DIR/versions/$DISPLAY_NAME/$DISPLAY_NAME.jar"

if [ -f "$JAR_PATH" ]; then
  echo "指定された表示名のバージョンは既に存在します。上書きして続行しますか？(Y/n)"
  read OVERWRITE
  case $OVERWRITE in
    [Nn]* )
      echo "中断しました。"
      return 2>&- || exit
      ;;
    * )
      echo "Yes"
      echo
  esac
fi

if ! type "jq" > /dev/null 2>&1; then
  echo "jqが見つかりません。インストールしますか？(Y/n)"
  read INS_JQ
  case $INS_JQ in
    [Nn]* )
      echo "中断しました。"
      return 2>&- || exit
      ;;
    * )
      echo "Yes"
  esac
  if [ $OS = "MacOS" ]; then
    if ! type "brew" > /dev/null 2>&1; then
      echo "homebrewが見つかりません。インストールしますか？(Y/n)"
      read INS_BREW
      case $INS_BREW in
        [Nn]* )
          echo "中断しました。"
          return 2>&- || exit
          ;;
        * )
          echo "Yes"
      esac
      echo "「Press RETURN to continue・・・」と表示されたら、RETURNを押してください。"
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
    echo "jqのインストール中です。"
    brew install jq
  else
    if type "yum" > /dev/null 2>&1; then
      echo "パスワードが要求された場合は入力してください。"
      sudo yum install epel-release -y
      sudo yum install jq --enablerepo=epel -y
    elif type "apt" > /dev/null 2>&1; then
      echo "パスワードが要求された場合は入力してください。"
      sudo apt install -y jq
    else
      echo "[ERROR] インストールに失敗しました。このスクリプトの動作にはjqが必要です。インストールして再度お試しください。"
      echo "中断しました。"
      return 2>&- || exit
    fi
  fi
fi

if ! type "jq" > /dev/null 2>&1; then
  echo "[INFO] jqをインストールされたことが確認できないため、中断しました。"
  return 2>&- || exit
fi

if ! type "7z" > /dev/null 2>&1; then
  echo "p7zipが見つかりません。インストールしますか？(Y/n)"
  read INS_SZIP
  case $INS_SZIP in
    [Nn]* )
      echo "中断しました。"
      return 2>&- || exit
      ;;
    * )
      echo "Yes"
  esac
  if [ $OS = "MacOS" ]; then
    brew install p7zip
  else
    if type "yum" > /dev/null 2>&1; then
      echo "パスワードが要求された場合は入力してください。"
      sudo yum install epel-release -y
      sudo yum install p7zip --enablerepo=epel -y
    elif type "apt" > /dev/null 2>&1; then
      echo "パスワードが要求された場合は入力してください。"
      sudo apt install -y p7zip
    else
      echo "[ERROR] インストールに失敗しました。このスクリプトの動作にはp7zipが必要です。インストールして再度お試しください。"
      echo "中断しました。"
      return 2>&- || exit
    fi
  fi
  if ! type "7z" > /dev/null 2>&1; then
    echo "[INFO] p7zipをインストールされたことが確認できないため、中断しました。"
    return 2>&- || exit
  fi
fi

# jarのコピー
echo -e "\n[Progress] jarファイルをコピーしています。\n"
mkdir "$MINECRAFT_DIR/versions/$DISPLAY_NAME" 2>&-
cp -f "$MINECRAFT_DIR/versions/1.5.2/1.5.2.jar" "$JAR_PATH"

# JSONの書き込み
echo -e "\n[Progress] jsonファイルを書き込んでいます。\n"
VERSION_JSON_PATH="$SCRIPT_PATH/assets/dqm4.json"
if [ ! -f "$VERSION_JSON_PATH" ]; then
  echo "[ERROR] dqm4.jsonが見つかりません。本ファイルだけ別の場所に移動していませんか？"
  echo "[INFO] 中断しました。"
  return 2>&- || exit
fi

jq ".id|=\"$DISPLAY_NAME\"" ./assets/dqm4.json > "$MINECRAFT_DIR/versions/$DISPLAY_NAME/$DISPLAY_NAME.json"

echo -e "\n[Progress] libファイルを展開しています。\n"
7z x -bso0 -y -o"$MINECRAFT_DIR/lib/" "$LIB_PATH"

echo -e "\n[Progress] プロファイルを登録しています。\n"
PROFILE_PATH="$MINECRAFT_DIR/launcher_profiles.json"
echo "続行する上でGNU Core Utilitiesをインストールすることが推奨されます。(なくてもDQMの動作に支障はありません)インストールしますか？(y/N)"
read INS_COREUTILS
case $INS_COREUTILS in
  [Yy]* )
    echo "Yes"
    if [ $OS = "MacOS" ]; then
      brew install coreutils
    else
      if type "yum" > /dev/null 2>&1; then
        echo "パスワードが要求された場合は入力してください。"
        sudo yum install epel-release -y
        sudo yum install coreutils --enablerepo=epel -y
      elif type "apt" > /dev/null 2>&1; then
        echo "パスワードが要求された場合は入力してください。"
        sudo apt install -y coreutils
      else
        echo "[ERROR] インストールに失敗しました。このスクリプトの動作にはGNU Core Utilitiesが必要です。インストールして再度お試しください。"
        echo "中断しました。"
        return 2>&- || exit
      fi
    fi
    ;;
  * )
    echo "No"
esac

DATE=$(date -u +"%Y-%m-%dT%T.%3NZ")
jq ".profiles.\"$DISPLAY_NAME\"|={created: \"$DATE\", icon: \"Creeper_Head\", lastVersionId: \"$DISPLAY_NAME\", name: \"$DISPLAY_NAME\", type: \"custom\"}" "$PROFILE_PATH" > "$SCRIPT_PATH/launcher_profiles.json"
cp -f "$SCRIPT_PATH/launcher_profiles.json" "$PROFILE_PATH"

TEMP_PATH="$SCRIPT_PATH/extract-temp"
rm -r "$TEMP_PATH" 2>&-

echo -e "\n[Progress] Forgeを展開しています。\n"

FORGE_TEMP_PATH="$SCRIPT_PATH/extract-temp/Forge"
7z x -bso0 -y -o"$FORGE_TEMP_PATH" "$FORGE_PATH"

echo -e "\n[Progress] jarファイルにForgeを書き込んでいます。\n"

7z a -bso0 -y "$JAR_PATH" "$FORGE_TEMP_PATH/*"

echo -e "\n[Progress] jarファイルからMETA-INFを削除しています。\n"

7z d -bso0 -y "$JAR_PATH" "META-INF"

echo -e "\n[Progress] 前提MODを展開しています。\n"

PREMISE_TEMP_PATH="$SCRIPT_PATH/extract-temp/DQMPremiseMod"
7z x -bso0 -y -o"$PREMISE_TEMP_PATH" "$PREMISE_PATH"

echo -e "\n[Progress] jarファイルに前提MODを書き込んでいます。\n"

7z a -bso0 -y "$JAR_PATH" "$PREMISE_TEMP_PATH/*"

echo -e "\n[Progress] DQM音声・BGMファイルを展開しています。\n"

7z x -bso0 -y -o"$MINECRAFT_DIR" "$BGM_PATH"

echo -e "\n[Progress] 本体MODをコピーしています。\n"

mkdir -p "$MINECRAFT_DIR/mods"
cp -f  "$BODY_PATH" "$MINECRAFT_DIR/mods/"

echo -e "\n[Progress] バニラSEをダウンロードしています。\n"

if ! type "wget" > /dev/null 2>&1; then
  echo "wgetが見つかりません。インストールしますか？(Y/n)"
  read INS_WGET
  case $INS_WGET in
    [Nn]* )
      echo "中断しました。"
      return 2>&- || exit
      ;;
    * )
      echo "Yes"
  esac
  if [ $OS = "MacOS" ]; then
    brew install wget
  else
    if type "yum" > /dev/null 2>&1; then
      echo "パスワードが要求された場合は入力してください。"
      sudo yum install epel-release -y
      sudo yum install wget --enablerepo=epel -y
    elif type "apt" > /dev/null 2>&1; then
      echo "パスワードが要求された場合は入力してください。"
      sudo apt install -y wget
    else
      echo "[ERROR] インストールに失敗しました。このスクリプトの動作にはp7zipが必要です。インストールして再度お試しください。"
      echo "中断しました。"
      return 2>&- || exit
    fi
  fi
  if ! type "wget" > /dev/null 2>&1; then
    echo "[INFO] wgetをインストールされたことが確認できないため、中断しました。"
    return 2>&- || exit
  fi
fi

wget -P"$TEMP_PATH" "https://app.chikach.net/dist/resources.zip" -q --show-progress

echo -e "\n[Progress] バニラSEを展開しています。\n"

7z x -bso0 -y -o"$MINECRAFT_DIR" "$TEMP_PATH/resources.zip"

echo -e "\n[Progress] プレイヤー名の取得中です。\n"
PLAYER_COUNT=$(jq '.. | select(.displayName?) | length' "$MINECRAFT_DIR/launcher_profiles.json" | wc -l)
declare -a PLAYERS=();
PLAYERS=$(jq '.. | select(.displayName?).displayName' "$MINECRAFT_DIR/launcher_profiles.json")
set_skin () {
  mkdir -p "$TEMP_PATH/skin/mob"
  cp -f "$SKIN_PATH" "$TEMP_PATH/skin/mob/$1.png"
}
apply_skin () {
  7z a -bso0 -y "$JAR_PATH" "$TEMP_PATH/skin/*"
}
if [ $PLAYER_COUNT -gt 1 ]; then
  echo "ログインされているアカウントにプレイヤーが複数存在します。"
  echo "どのプレイヤーにスキンを設定しますか？"
  echo
  for PLAYER in ${PLAYERS[@]}; do
    echo $PLAYER | tr -d '"'
  done
  echo "全てに設定(a)"
  read SELECTED_PLAYER


  case $SELECTED_PLAYER in
    [Aa]* )
      echo "All"
        for PLAYER in ${PLAYERS[@]}; do
          set_skin "$(echo $PLAYER | tr -d '\"')"
        done
        apply_skin
      ;;
    * )
      for PLAYER in ${PLAYERS[@]}; do
        if [ "$(echo $PLAYER | tr -d '\"')" = "$SELECTED_PLAYER" -a -z "$USER_SELECTED" ]; then
          USER_SELECTED=1
          set_skin "$(echo $PLAYER | tr -d \"\\\"\")"
          apply_skin
        fi
      done
      if [ -z "$USER_SELECTED" ]; then
        echo "プレイヤーが選択されませんでした。スキンは設定されません。ご注意ください。"
      fi
  esac

else
  set_skin "$(echo ${PLAYERS} | tr -d '\"')"
  apply_skin
fi

echo
echo -e "\n[INFO] インストールが完了しました！"
echo "[INFO] Enterを押すと終了します。"
read
echo "クリーンアップ中です。(一時保存ファイルを削除しています。)"
rm -r "$TEMP_PATH"
rm "$SCRIPT_PATH/launcher_profiles.json"
