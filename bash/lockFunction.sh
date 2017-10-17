## 関数の定義ファイル

## グローバル変数の定義
LOCK_FILE=

## シェル終了時に必ずロックファイルを削除する
trap "unlock; exit" 0 1 2 3 15

## ロック(排他ロック)
# arg[1] : ロックファイル
#
function lock(){
  if [ $# -lt 1 ];then
    echo "lock: ロックファイルを引数に指定してください"
    exit 1
  elif [ $# -gt 1 ]; then
    echo "lock: 引数の数が多すぎます"
    exit 1
  fi
  # ロックファイルを引数から取得
  LOCK_FILE=${1}
  echo ${LOCK_FILE}のロックを取得します
  while true
  do
    if ln -s $$ ${LOCK_FILE} 2> /dev/null; then
      # ロック取得できた
      echo ロックを取得しました
      break
    else
      # ロックファイルが既に存在している場合
      # ロックファイルから作成元の PID を取得する
      if [ -d /proc/`readlink ${LOCK_FILE}` ]; then
        # プロセスが存在する場合プロセスの終了まで待機
        wait
      else
        # プロセスが存在しない場合はロックファイルを削除してリトライ
        unlink ${LOCK_FILE}
      fi
    fi
  done
  return 0
}

## ロック解除
function unlock(){
  ## LOCK_FILE変数が空ならメッセージを出力して終了
  if [ -z "${LOCK_FILE}" ]; then
    echo 'ロックファイル変数が何も指していません(null)'
    return 1
  fi
  # lockファイルが存在する かつ 現在のPIDとロックファイルの指すPIDが等しい場合
  if [ -L ${LOCK_FILE} ] && [ $$ = `readlink ${LOCK_FILE}` ]; then
    unlink ${LOCK_FILE}
    echo ${LOCK_FILE}のロックを解除しました
    LOCK_FILE=   # nullセット
  fi
  return 0
}
