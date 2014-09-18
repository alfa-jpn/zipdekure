module Zipdekure
  # 住所クラス
  #
  # @attr code        [String]  全国地方公共団体コード(5桁)
  # @attr zip_code    [String]  7桁の郵便番号
  # @attr pref_code   [Integer] 都道府県番号
  # @attr city        [String]  市区町村名
  # @attr city_kana   [String]  市区町村名(半角カナ)
  # @attr area        [String]  町域
  # @attr area_kana   [String]  町域(半角カナ)
  # @attr number      [String]  番地
  # @attr number_kana [String]  番地(半角カナ)
  # @attr name        [String]  名称
  # @attr name_kana   [String]  名称(半角カナ)
  # @attr office      [Boolean] 大口事業所の個別番号かどうか
  # @attr flags       [Array]   CSV読み取りフラグ(CSVからの読み取り時のみ使用)
  class Address
    attr_accessor *[
      :code,
      :zip_code,
      :pref_code,
      :city,
      :city_kana,
      :area,
      :area_kana,
      :number,
      :number_kana,
      :name,
      :name_kana,
      :flags,
      :office
    ]

    # Address同士を連結した新しいインスタンスを返す。
    # @note 町域のみが連結され、他のデータは変化しない。
    def +(other)
      dup.tap do |adr|
        adr.area      += other.area
        adr.area_kana += other.area_kana
      end
    end
  end
end
