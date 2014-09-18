module Zipdekure::Parsers
  # 日本郵便の`ken_all.csv`から`Zipdekure::Address`の配列を生成するためのParser
  class Jigyosyo < Zipdekure::Parsers::Base
    private
    # 行のフォーマットを確認する。
    # @raise フォーマットがおかしい場合は例外が発生する。
    def check_row_format!(row)
      raise 'jigyosyo.csvのカラム数が異常です。' unless row.length == 13
    rescue
      p row
      raise
    end

    # ken_all.csvをパースする。
    # @return [Array<Zipdekure::Address>] Zipdekure::Addressの配列
    def parse
      Array.new.tap do |data|
        Zipdekure::CSV::Jigyosyo.open do |csv|
          csv.each do |row|
            check_row_format!(row)
            data << Zipdekure::Address.new.tap do |address|
              address.code      = row[0]
              address.zip_code  = row[7]
              address.pref_code = address.code[0, 2].to_i
              address.city      = row[4]
              address.area      = row[5]
              address.number    = row[6]
              address.name      = row[2]
              address.name_kana = row[1]
              address.flags     = row.last(3)
              address.office    = true
            end
          end
        end
      end
    end
  end
end
