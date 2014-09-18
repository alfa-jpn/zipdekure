module Zipdekure::CSV
  # 日本郵便の`jigyosyo.zip`からCSVを抽出して読み込むためのクラス。
  class Jigyosyo < Zipdekure::CSV::Base
    # ZIPデータのURLを取得する。
    # @abstract 継承後上書きする。
    # @return [String] ZIPデータのURL
    def archive_url
      'http://www.post.japanpost.jp/zipcode/dl/jigyosyo/zip/jigyosyo.zip'
    end

    # キャッシュファイルのパスを取得する。
    # @abstract 継承後上書きする。
    # @return [String] キャッシュファイルのパス
    def cached_csv_path
      File.join(Zipdekure::ROOT_DIR, 'vendor', 'jigyosyo.csv')
    end

    # CSVファイルの名前を取得する。
    # @abstract 継承後上書きする。
    # @return [String] CSVファイルの名前
    def csv_file_name
      'JIGYOSYO.CSV'
    end
  end
end
