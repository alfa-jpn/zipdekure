require 'spec_helper'
require 'yaml'

describe Zipdekure::Parsers::Jigyosyo do
  context '#addresses' do
    before :all do
      @addresses = Zipdekure::Parsers::Jigyosyo.new.addresses
    end

    subject do
      @addresses
    end

    let :samples do
      YAML.load_file(File.join(Zipdekure::ROOT_DIR, 'spec', 'fixtures', 'jigyosyo.yml'))
    end

    it 'Zipdekure::Addressesの配列が返されること' do
      subject.each do |address|
        expect(address.kind_of?(Zipdekure::Address)).to be_truthy
      end
    end

    it '事業所フラグが真であること' do
      subject.each do |address|
        expect(address.office).to be_truthy
      end
    end

    it 'fixtures/jigyosyo.ymlとデータが一致すること' do
      subject.each do |address|
        samples.reject! do |sample|
          sample['code']      == address.code      &&
          sample['zip_code']  == address.zip_code  &&
          sample['pref_code'] == address.pref_code &&
          sample['city']      == address.city      &&
          sample['area']      == address.area      &&
          sample['number']    == address.number    &&
          sample['name']      == address.name      &&
          sample['name_kana'] == address.name_kana
        end
      end
      expect(samples).to eq([])
    end
  end
end
