# OrthoFinder Orthogroup Summary Tool

OrthoFinder の orthogroup 出力を要約し、
比較ゲノム解析などの下流解析に利用しやすい
簡潔な TSV ファイルを生成する軽量な R スクリプトです。

---

## 背景

OrthoFinder は非常に情報量の多い orthogroup 出力を提供しますが、
多くの下流解析では **遺伝子リストそのものではなく数値的な集計結果**
のみが必要になることがあります。

本ツールは以下を重視しています：

* 数値情報のクリーンな集計
* 依存関係を最小限に抑える（base R のみ）
* 解析パイプラインへの容易な組み込み

---

## 入力ファイル

本スクリプトは、OrthoFinder によって生成される
以下のファイルを入力として想定しています：

* `Orthogroups.GeneCount.tsv`
* `Orthogroups.tsv`

---

## 使用方法

`Rscript` を用いて以下のように実行します：

```bash
Rscript scripts/summarize_orthogroups.R \
  --gene_count Orthogroups.GeneCount.tsv \
  --orthogroups Orthogroups.tsv \
  --species XL,XT \
  --out_prefix XL_XT
利用可能なすべてのオプションを確認するには：

```bash
Rscript scripts/summarize_orthogroups.R --help

##出力

* <out_prefix>.summary.tsv
出力される TSV ファイルには以下の情報が含まれます：
* Orthogroup ID
* 全体の遺伝子数
* 各種ごとの遺伝子数
* 各種ごとの遺伝子メンバー一覧
この TSV ファイルは、R・Python・Excel などにそのまま読み込んで 下流解析に利用できます。
`examples/` ディレクトリに出力例（example_summary.tsv）を含めています。

##設計思想
本ツールは、意図的に以下を 行いません：
* 統計解析
* 可視化（プロット生成）
* OrthoFinder 出力の改変
目的は、ユーザーが自由に加工・解析できる 数値的に整理された中間データを提供することです。

##想定ユーザー
* 比較ゲノム研究者
* 進化生物学研究者
* バイオインフォマティクスのパイプライン開発者

##動作環境
* R (>= 3.6)
* 追加パッケージ不要

##引用
本スクリプトを研究で使用した場合は、 以下の論文を引用してください：
* Emms, D. M. & Kelly, S. (2019) OrthoFinder

##ライセンス
MIT License Copyright (c) 2026 Ryota Ichikawa



