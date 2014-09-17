require 'csv'
require 'open-uri'
require 'zip'

module Zipdekure::CSV
  # ZIPをダウンロードし、中身のCSVを取得するためのクラス。
  # @abstract 継承して使用する。
  class Base
    attr_accessor *[
      :enabled_cache,
      :working_directory
    ]

    # 初期化する。
    # @param enabled_cache [Boolean] キャッシュを有効にするかどうか
    def initialize(enabled_cache)
      @enabled_cache = enabled_cache
    end

    # CSVファイルをキャッシュする。
    # @return [Boolean] キャッシュに成功した場合は真を返す。
    def cache
      unless csv_path == cached_csv_path
        FileUtils.copy(csv_path, cached_csv_path)
        File.exists?(cached_csv_path)
      else
        false
      end
    end

    def close
      clean_working_directory
    end

    # CSVのパスを取得する。
    def csv_path
      @csv_path ||= find_cache_or_download
    end

    # ファイルのハッシュ値を取得する。
    # @return [String] SHA256ハッシュ
    def digest
      Digest::SHA256.file(csv_path)
    end

    # CSVを一行ずつ読み込みブロック実行する。
    # @yield [row] 実行するブロック
    # @yieldparam row [Array] 読み取った行
    def each(&block)
      csv = CSV.open(csv_path, "r:#{encoding}:utf-8")
      csv.each &block
      csv.close
    rescue
      csv.close
      raise
    end

    # ファイルのエンコードを取得する。
    # @abstract shift_jis以外のエンコードの場合は継承後オーバライドする。
    # @return [String] ファイルのエンコード
    def encoding
      'shift_jis'
    end

    # キャッシュもしくはZIPデータをダウンロードしCSVを取得する。
    # @return [String] CSVのパス
    def find_cache_or_download
      if @enabled_cache and File.exists?(cached_csv_path)
        cached_csv_path
      else
        download_csv
      end
    end

    # CSVを取得しインスタンスをブロックで処理する。
    # @param enabled_cache [Boolean] キャッシュを有効にするかどうか
    # @yield [csv] CSVのインスタンスを処理する。
    # @yieldparam csv [Zipdekure::CSV::Base] CSVのインスタンス
    def self.open(enabled_cache = true)
      csv = new(enabled_cache)
      yield csv
      csv.close
    rescue
      csv.close
      raise
    end

    # ZIPデータのURLを取得する。
    # @abstract 継承後上書きする。
    # @return [String] ZIPデータのURL
    def archive_url
      raise 'CSVBase#archive_urlがオーバーライドされずに呼び出されました。'
    end

    # キャッシュファイルのパスを取得する。
    # @abstract 継承後上書きする。
    # @return [String] キャッシュファイルのパス
    def cached_csv_path
      raise 'CSVBase#cache_fileがオーバーライドされずに呼び出されました。'
    end

    # CSVファイルの名前を取得する。
    # @abstract 継承後上書きする。
    # @return [String] CSVファイルの名前
    def csv_file_name
      raise 'CSVBase#csv_file_nameがオーバーライドされずに呼び出されました。'
    end

    private
    private_class_method :new

    # 作業ディレクトリを生成する。
    # @return [String] 作業ディレクトリ
    def create_working_directory
      return if @working_directory

      loop do
        @working_directory = File.join(Zipdekure::TMP_DIR, Time.now.to_i.to_s)
        break unless Dir.exists?(@working_directory)
      end
      FileUtils.mkdir_p(@working_directory)
    end

    # 作業ディレクトリを破棄する。
    def clean_working_directory
      if @working_directory
        FileUtils.rm_rf(@working_directory)
        @working_directory = nil
      end
    end

    # ファイルをダウンロードする。
    #
    # @param url [String] ダウンロードURL
    # @return [String] ダウンロードしたファイルのパス
    def download(url)
      File.join(@working_directory, File.basename(url)).tap do |path|
        open(path, 'wb') do |writer|
          open(url, 'rb') {|reader| writer.write(reader.read)}
        end
      end
    end

    # CSVをダウンロードする。
    # @return [String] ダウンロードしたCSVのパス
    def download_csv
      create_working_directory
      zip_path = download(archive_url)
      extract!(zip_path, csv_file_name)
    end

    # ZIPファイルから指定されたファイルを取り出す。
    #
    # @param zip  [String] ZIPファイルのパス
    # @param name [String] 取り出すファイル名
    # @return [String] 取り出したファイルのパス
    def extract!(zip, name)
      File.join(@working_directory, name).tap do |file|
        Zip::File.open(zip) do |zip|
          zip.each do |entry|
            entry.extract(file) if entry.name == name
          end
        end
        raise IOError, "#{name}の展開に失敗しました。" unless File.exist?(file)
      end
    end
  end
end
