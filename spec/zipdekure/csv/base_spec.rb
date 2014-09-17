require 'spec_helper'

describe Zipdekure::CSV::Base do
  let :inherited_class do
    Zipdekure::CSV::KenALL
  end

  describe '.open' do
    it 'ブロックにCSVのインスタンスが渡されること' do
      inherited_class.open do |csv|
        expect(csv.kind_of?(Zipdekure::CSV::Base)).to be_truthy
      end
    end
  end

  describe '#csv_path' do
    context 'キャッシュが有効な場合' do
      it 'キャッシュが参照されること' do
        inherited_class.open do |csv|
          expect(csv.csv_path).to eq(csv.cached_csv_path)
        end
      end
    end
  end

  describe '#each' do
    it '少なくとも1回以上実行されること' do
      inherited_class.open do |csv|
        exec_count = 0
        csv.each do |row|
          expect(row.kind_of?(Array)).to be_truthy
          exec_count += 1
        end
        expect(exec_count).to be > 0
      end
    end
  end
end
