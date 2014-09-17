require 'spec_helper'
require 'yaml'

describe Zipdekure::Parsers::KenALL do
  context '#addresses' do
    before :all do
      @addresses = Zipdekure::Parsers::KenALL.new.addresses
    end

    subject do
      @addresses
    end

    let :samples do
      YAML.load_file(File.join(Zipdekure::ROOT_DIR, 'spec', 'fixtures', 'ken_all.yml'))
    end

    it 'Zipdekure::Addressesの配列が返されること' do
      subject.each do |address|
        expect(address.kind_of?(Zipdekure::Address)).to be_truthy
      end
    end

    it 'fixtures/ken_all.ymlとデータが一致すること' do
      subject.each do |address|
        samples.reject! do |sample|
          sample['code']      == address.code      &&
          sample['zip_code']  == address.zip_code  &&
          sample['pref_code'] == address.pref_code &&
          sample['city']      == address.city      &&
          sample['city_kana'] == address.city_kana &&
          sample['area']      == address.area      &&
          sample['area_kana'] == address.area_kana
        end
      end
      expect(samples).to eq([])
    end
  end
end
