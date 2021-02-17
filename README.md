# radiko_sh
radiko用Shellスクリプトです。
もともと[radikoの仕様変更で録音ができなくなる問題を修正 \| 忘れたらググればいい](http://fukubaya.blogspot.com/2012/10/radiko.html)にあったスクリプトを修正したものです。

## Usage
```
 radiko.ksh (ID) (出力ファイル名) (time) [-t (タイトル)] [-a (アーティスト)] [-A (アルバム名)] [-g (ジャンル)]
```
 - ID: Radikoのステーション名 [Radiko Player 放送局ID 一覧 – ノリキスタジオ](https://www.norikistudio.com/station-id-list)などを参照
 - 出力ファイル名: 出力ファイル名(拡張子は不要 m4aで保存)
 - time: 時間(分単位で記入)
## ToDo
  - [x] メタ情報が追加できない
  - [x] mp3で保存出来ていない

## Refer
 - [radish/radi\.sh at master · uru2/radish](https://github.com/uru2/radish/blob/master/radi.sh)
 - [rec\_radiko/rec\_radiko\.sh at master · yyyjajp/rec\_radiko](https://github.com/yyyjajp/rec_radiko/blob/master/rec_radiko.sh)
 - [FFmpeg：雑多な形式の音楽ファイルをmp3かm4aに一括変換するコマンド \| SlackNote](https://slacknotebook.com/encoding-various-sound-files-to-m4a-mp3-with-ffmpeg/)

