# Amazon EC2 に Gfarm/Pwrake 環境を構築
## 説明

* Amazon EC2 (Elastic Compute Cloud) に、
分散ファイルシステムGfarmと、ワークフローシステムPwrake
の環境を構築したインスタンスを起動し、Pwrakeのデモとして、
天文画像処理ソフトウエアMontageの実行を行います。

* クラウド環境の自動構築のため、Amazon CloudFormation を使用。
そのテンプレートは、本パッケージに含まれるスクリプトにより自動生成。

* Gfarmを起動するノードでは、ホスト名を固定する必要があるため、
Amazon VPC (Virtual Private Cloud) で仮想ネットワークを作成し、
固定アドレスのインスタンスを作成。

* 作成するインスタンス
  * MDS (MetaData Server): ログインノードとPwrake実行ノードを兼ねる
  * FSN (File System Nodes): 計算ノードを兼ねる。複数作成可能

* デフォルトでは、1年間の無料枠範囲内の t2.micro のインスタンスを作成。

* 下記のコマンドライン入力は、bash を想定

## 必要なソフトウエア

次のソフトウエアを使えるようにしておく
* AWS-CLI (Command Line Intefarce) : コマンドラインからAWSを操作
  * http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html

* Ruby (>=2.0)

* cfndsl: Amazon CloudFormation のテンプレートをDSLで作成するツール。
Rubygemsでインストールする。

        $ gem install cfndsl

* 本パッケージ： 取得方法

        $ git clone https://github.com/masa16/amazon-ec2-gfarm-demo.git
        $ cd amazon-ec2-gfarm-demo
  または

      $ wget https://github.com/masa16/amazon-ec2-gfarm-demo/archive/master.tar.gz -O - | tar xzf -
      $ cd amazon-ec2-gfarm-demo-master

## Gfarmインスタンスの構築

* AWSにサインアップ

* AWSコンソールから
[アクセスキーIDと秘密アクセスキーを取得](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html)
し、AWS-CLIの設定を行う：

        $ aws configure
        AWS Access Key ID [None]: アクセスキーIDを入力
        AWS Secret Access Key [None]: 秘密アクセスキーを入力
        Default region name [None]: デフォルトリージョンを入力
        Default output format [None]: デフォルト出力フォーマットを入力

* [env.sh](https://github.com/masa16/amazon-ec2-gfarm-demo/blob/master/env.sh) を見て、設定を確認

* 次のスクリプトで、SSH鍵を作成し、公開鍵をAWSにアップロードする

        $ sh setup-keypair.sh

  * ここでパスワードを設定

* 環境構築状況を確認できるように、ブラウザからAWSコンソールを開いておく。
  * https://console.aws.amazon.com

* 次のスクリプトで、CloudFormation でスタックを作成

        $ sh create-stack.sh

    * 作成するFSNインスタンスの数を尋ねるので、数字を入力する。

            Number of File System Nodes? : 10

    * 5分程度待つと(t2.micro)、Gfarm環境が構築される。
    * 自動的にcfndslで作成されたCloudFormationのテンプレート(json)に基づいて構築。
    * ブラウザからAWSコンソールを開き、インスタンスの作成状況を確認する。
    * 1個のMDSインスタンスとn個のFNSインスタンスが作られる。
    * Gfarmなどのソフトウエアも自動的にインストールされる。

* インスタンスが作成されたら、次のスクリプトでsshの設定を行う

        $ sh setup-ssh.sh

    * ~/.ssh/config に自動的に設定を追加するので、確認する。
    * EC2のログインアカウント:
      * ec2-user (Amazon Linuxの場合)
    * ホスト名のエイリアス:
      * MDS: aws-mds
      * FSN: aws-cn11, aws-cn12, ..
    * FSNへの接続は、aws-mdsを経由する。
    * SSH agent forwarding を用いるので、手元のマシンで ssh-agent を立ち上げておく。
    * MDSとFSNの ~/.ssh/config も設定している。

* MDSにログインし、Gfarmが起動していることを確認

        $ ssh aws-mds

        [ec2-user@ip-10-0-0-10 ~]$ gfdf
            1K-blocks          Used         Avail Use% Host
              8023564       1772852       6250712  22% ip-10-0-0-10.us-west-2.compute.internal
        ----------------------------------------------
              8023564       1772852       6250712  22%

* 次のスクリプトで、MDSの設定をFSNにコピーし、gfsdを起動する。

        $ sh setup-gfsd.sh

        [ec2-user@ip-10-0-0-10 ~]$ gfdf
            1K-blocks          Used         Avail Use% Host
              8023564       1772968       6250596  22% ip-10-0-0-10.us-west-2.compute.internal
              8023564       1584792       6438772  20% ip-10-0-0-11.us-west-2.compute.internal
              8023564       1584792       6438772  20% ip-10-0-0-12.us-west-2.compute.internal
              8023564       1584792       6438772  20% ip-10-0-0-13.us-west-2.compute.internal
              8023564       1584792       6438772  20% ip-10-0-0-14.us-west-2.compute.internal
              8023564       1584792       6438772  20% ip-10-0-0-15.us-west-2.compute.internal
              8023564       1584796       6438768  20% ip-10-0-0-16.us-west-2.compute.internal
              8023564       1584792       6438772  20% ip-10-0-0-17.us-west-2.compute.internal
              8023564       1584792       6438772  20% ip-10-0-0-18.us-west-2.compute.internal
              8023564       1584792       6438772  20% ip-10-0-0-19.us-west-2.compute.internal
              8023564       1584792       6438772  20% ip-10-0-0-20.us-west-2.compute.internal
        ----------------------------------------------
             88259204      17620892      70638312  20%

## Pwrakeのデモ

* ここでは、天文画像処理ソフトウエアのMontageのワークフローを、
並列ワークフロー実行システムPwrakeにより実行するデモを行う。
* 上記の構築で、すでにPwrakeとMontageソフトウェアはインストールされている。
* 次のスクリプトで、ワークフローの設定と入力ファイルをGfarmファイルシステムにコピーする。

        $ sh prepare-demo.sh

* 次の手順で、ワークフローを実行する

        $ ssh aws-mds

        [ec2-user@ip-10-0-0-10 ~]$ cd gfm/montage-m31
        [ec2-user@ip-10-0-0-10 montage-m31]$ pwrake

* 実行ログが log_20150904-... のような名前のディレクトリに出力されるので、
そこから統計情報をHTMLで出力

        [ec2-user@ip-10-0-0-10 montage-m31]$ pwrake --report log_*

* HTTP経由でGfarmのディレクトリにアクセス

        $ firefox http://$(cat MdsDnsName)/gfarm

  * shrunk.jpg が結果の画像
  * log_2015*/report.html が統計情報のページ

## 起動・停止

* インスタンスの停止（EBSにインスタンスは残る）

        $ sh stop-instances.sh

* インスタンスの再開

        $ sh start-instances.sh

* CloudFormationのスタックを消去（インスタンスも消去）

        $ sh delete-stack.sh
