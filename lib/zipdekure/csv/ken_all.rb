module Zipdekure::CSV
  # 日本郵便の`ken_all.zip`から
  # @abstract 継承して使用する。
  class KenALL < Zipdekure::CSV::Base
    # ZIPデータのURLを取得する。
    # @abstract 継承後上書きする。
    # @return [String] ZIPデータのURL
    def archive_url
      'http://www.post.japanpost.jp/zipcode/dl/kogaki/zip/ken_all.zip'
    end

    # キャッシュファイルのパスを取得する。
    # @abstract 継承後上書きする。
    # @return [String] キャッシュファイルのパス
    def cached_csv_path
      File.join(Zipdekure::ROOT_DIR, 'vendor', 'ken_all.csv')
    end

    # CSVファイルの名前を取得する。
    # @abstract 継承後上書きする。
    # @return [String] CSVファイルの名前
    def csv_file_name
      'KEN_ALL.CSV'
    end
  end
end
