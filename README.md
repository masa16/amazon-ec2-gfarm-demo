# Amazon EC2 に Gfram/Pwrake 環境を構築
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

## 必要なソフトウエア

次のソフトウエアを使えるようにしておく
* AWS-CLI (Command Line Intefarce) : コマンドラインからAWSを操作
  * http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html

* Ruby (>=2.0)

* cfndsl : Amazon CloudFormationのテンプレートをDSLで作成するツール。
Rubygemsでインストールする。

        gem install cfndsl

* 本パッケージ: 取得方法は、

        git clone https://github.com/masa16/amazon-ec2-gfarm-demo.git
        cd amazon-ec2-gfarm-demo

または

        wget https://github.com/masa16/amazon-ec2-gfarm-demo/archive/master.tar.gz -O - | tar xzf -
        cd amazon-ec2-gfarm-demo-master

## Gfarmインスタンスの構築

* AWSにサインアップ

* AWS-CLIでAWSにアクセスできるようにする

        aws configure

* env.sh を見て、設定を確認

* SSHで KeyPair を作成し、公開鍵をAWSにアップロードする

        sh setup-keypair.sh

  * パスワードを設定

* 環境構築状況を確認できるように、ブラウザからAWSコンソールを開いておく。
  * https://console.aws.amazon.com

* CloudFormation でスタックを作成

        sh create-stack.sh

    * 作成するFSNインスタンスの数を尋ねるので、数字を入力する。
    * 自動的にcfndslでCloudFormationのテンプレートを作成し、環境構築を行っている。
    * ブラウザからAWSコンソールを開き、インスタンスの作成状況を確認する。
    * 1個のMDSインスタンスとn個のFNSインスタンスが作られる。
    * Gfarmなどのソフトウエアも自動的にインストールされる。

* インスタンスが作成されたら、sshの設定を行う

        sh setup-ssh.sh

    * ~/.ssh/config に自動的に設定を追加するので、確認する。
    * EC2のログインアカウント: ec2-user
    * ホスト名のエイリアス
      * MDS: aws-mds
      * FSN: aws-cn11, aws-cn12, ..
    * FSNへの接続は、aws-mdsを経由
    * エージェントフォワード
    * MDSとFSNの ~/.ssh/config も設定している。

* MDSにログインし、Gfarmが起動していることを確認

        ssh aws-mds
        gfdf

* FSNの設定は、次のスクリプトで行う必要がある。

        sh setup-gfsd.sh
        gfdf

## Pwrakeのデモ

* ここでは、天文画像処理ソフトウエアのMontageのワークフローを、
並列ワークフロー実行システムPwrakeにより実行するデモを行う。
* 上記の構築で、すでにPwrakeとMontageソフトウェアはインストールされている。
* 次のスクリプトで、ワークフローの設定と入力ファイルをGfarmファイルシステムにコピーする。

        sh prepare-demo.sh

* 次の手順で、ワークフローを実行する

        ssh aws-mds
        cd gfm/montage-m31
        pwrake

* 実行ログが log_20150904-... のような名前のディレクトリに出力されるので、
そこから統計情報をHTMLで出力

        # Gnuplot font
        export GDFONTPATH=/usr/share/fonts/dejavu
        export GNUPLOT_DEFAULT_GDFONT=DejaVuSans
        pwrake --report=log_*

* 実行結果のファイルをローカルにコピー

        scp aws-mds:gfm/montage-m31/shrunk.jpg .
        scp -r aws-mds:gfm/montage-m31/log_* .

* 結果の確認（例）

        display shrunk.jpg
        firefox log*/report.html

## 起動・停止

* インスタンスの停止（EBSにインスタンスは残る）

        sh stop-instances.sh

* インスタンスの再開

        sh start-instances.sh

* CloudFormationのスタックを消去（インスタンスも消去）

        sh delete-stack.sh
