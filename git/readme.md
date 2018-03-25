# gitsurvey

## Outline
このパッケージは、gitリポジトリの初期のサイズと現在のサイズを計算し、今までのコミット数から将来のリポジトリサイズを予測するものです。

## Usage
1. change settings REPO_ROOT in printAchaicRepositorySize.sh and printCurrentRepositorySize.sh
2. execute -> `./printAchaicRepositorySize.sh` and `./printCurrentRepositorySize.sh`
e.g.)
```
./printAchaicRepositorySize.sh 2>&1 | tee achaic.log
./printCurrentRepositorySize.sh 2>&1 | tee current.log
```
3. Formatting Logfile
e.g.)
```
grep SIZE achaic.log | awk '{sub(/\[/,"",$6);sub(/\]/,"",$6);printf "%s\t%s\n",$6,$4}' > achaicsize.log
grep SIZE current.log | awk '{sub(/\[/,"",$6);sub(/\]/,"",$6);printf "%s\t%s\n",$6,$4}' > currentsize.log
```
4. excute -> `printRepositoryCommitNum.sh`
5. Calculate size at point of future.

## Note
printAchaicRepositorySize.sh  calclate repository size at 1stCommit.
printCurrentRepositorySize.sh calclate repozitory size at current point.
