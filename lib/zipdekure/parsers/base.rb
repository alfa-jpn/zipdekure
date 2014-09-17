module Zipdekure::Parsers
  # パーサーの基底クラス。
  # @abstract 継承後parseメソッドを実装する。
  class Base
    # パース済みのZipdekure::Addressの配列を返す。
    # @return [Array<Zipdekure::Address>] Zipdekure::Addressの配列
    def addresses
      @addresses ||= parse
    end

    private
    # データをパースする。
    # @abstract 継承後実装する。
    # @return [Array<Zipdekure::Address>] Zipdekure::Addressの配列
    def parse
      raise 'Zipdekure::Parsers::Base#parseが継承されずに使用されました。'
    end
  end
end
