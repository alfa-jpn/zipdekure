module Zipdekure::Parsers
  # 日本郵便の`ken_all.csv`から`Zipdekure::Address`の配列を生成するためのParser
  class KenALL < Zipdekure::Parsers::Base
    private
    # 行のフォーマットを確認する。
    # @raise フォーマットがおかしい場合は例外が発生する。
    def check_row_format!(row)
      raise 'ken_all.csvのカラム数が異常です。' unless row.length == 15
    rescue
      p row
      raise
    end

    # ken_all.csvをパースする。
    # @return [Array<Zipdekure::Address>] Zipdekure::Addressの配列
    def parse
      Array.new.tap do |decided_data|
        pending_data = read_csv
        decided_data.concat(extract_single_data!(pending_data))
        decided_data.concat(extract_splited_single_data!(pending_data))
        decided_data.concat(extract_double_data!(pending_data))
        decided_data.concat(extract_multiple_data!(pending_data))
        if pending_data.length > 0
          raise "`ken_all.csv`から#{pending_data.length}件のデータを解析できませんでした。"
        end
      end
    end

    # CSVを読み取る
    # @return [Hash<String,Array<Zipdekure::Address>>] 郵便番号をキーにした郵便番号データの配列
    def read_csv
      Hash.new.tap do |data|
        Zipdekure::CSV::KenALL.open do |csv|
          csv.each do |row|
            check_row_format!(row)
            address = Zipdekure::Address.new.tap do |address|
              address.code      = row[0]
              address.zip_code  = row[2]
              address.pref_code = address.code[0, 2].to_i
              address.city      = row[7]
              address.city_kana = row[4]
              address.area      = row[8]
              address.area_kana = row[5]
              address.flags     = row.last(6)
            end
            (data[address.zip_code] ||= Array.new) << address
          end
        end
      end
    end

    # 一つの郵便番号に対してデータを一つだけ保持するデータを破壊的に抽出する。
    # @param data [Hash<String,Array>] 郵便番号をキーにした郵便番号データの配列
    # @return [Array<Zipdekure::Address>] Zipdekure::Addressデータの配列
    def extract_single_data!(data)
      Array.new.tap do |decided_data|
        data.each do |zip_code, addresses|
          if addresses.length == 1
            decided_data.concat(addresses)
            data.delete(zip_code)
          end
        end
      end
    end

    # 一つの郵便番号に対して複数のデータを保持し、なおかつ複数割当フラグが偽のデータを破壊的に抽出する。
    # @note #extract_single_data! を実行したデータに対しての実行を想定。
    #  この時点で
    #  「複数割当フラグ(フラグ4)が偽かつ複数データが存在する」
    #   場合は、ひとつのデータが文字数制限で分割された状態と断定できる。
    #
    # @param data [Hash<String,Array>] 郵便番号をキーにした郵便番号データの配列
    # @return [Array<Zipdekure::Address>] Zipdekure::Addressデータの配列
    def extract_splited_single_data!(data)
      Array.new.tap do |decided_data|
        data.each do |zip_code, addresses|
          if addresses.all?{|address| address.flags[3] == '0' }
            decided_data << addresses.inject(:+)
            data.delete(zip_code)
          end
        end
      end
    end

    # 一つの郵便番号に対して2個のデータを保持しているデータを破壊的に抽出する。
    # @note #extract_splited_single_data! を実行したデータに対しての実行を想定。
    #  この時点で
    #  「一つの郵便番号に2個のデータが存在する」
    #   場合は、一つの郵便番号に対して複数の町域が存在するデータと断定できる。
    #
    # @param data [Hash<String,Array>] 郵便番号をキーにした郵便番号データの配列
    # @return [Array<Zipdekure::Address>] Zipdekure::Addressデータの配列
    def extract_double_data!(data)
      Array.new.tap do |decided_data|
        data.each do |zip_code, addresses|
          if addresses.length == 2
            decided_data.concat(addresses)
            data.delete(zip_code)
          end
        end
      end
    end

    # 一つの郵便番号に対して2個以上のデータを保持しているデータを破壊的に抽出する。
    # @note extract_double_data! を実行したデータに対しての実行を想定。
    #   この時点で残っているデータは下記のどちらかに該当する。
    #   ・一つの郵便番号に3つ以上の町域が割り当てられている。
    #   ・一つの郵便番号に2つ以上の町域が割り当てられ、2行に分割されたデータを含む。
    #
    #   「分割された行は結合した時にトークン(カッコ)の数が一致する」
    #    という憶測の元結合を行う。
    #
    # @param data [Hash<String,Array>] 郵便番号をキーにした郵便番号データの配列
    # @return [Array<Zipdekure::Address>] Zipdekure::Addressデータの配列
    def extract_multiple_data!(data)
      Array.new.tap do |decided_data|
        adr       = nil
        deep      = 0
        kana_deep = 0

        data.each do |zip_code, addresses|
          addresses.each do |address|
            if deep == 0 and kana_deep == 0
              adr = address
            else
              adr += address
            end

            # トークンの深さをカウントする。
            deep      += address.area.count('（') - address.area.count('）')
            kana_deep += address.area_kana.count('(') - address.area_kana.count(')')

            if deep == 0 and kana_deep == 0
              decided_data << adr
            end
          end
          data.delete(zip_code)
          raise 'トークンの深さがおかしいです。' if deep != 0 or kana_deep != 0
        end
      end
    end
  end
end
