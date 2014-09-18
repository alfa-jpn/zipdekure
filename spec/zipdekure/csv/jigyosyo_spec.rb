require 'spec_helper'

describe Zipdekure::CSV::KenALL do
  it '最新版のJIGYOSYO.CSVがキャッシュされていること' do
    Zipdekure::CSV::Jigyosyo.open(true) do |cache|
      Zipdekure::CSV::Jigyosyo.open(false) do |raw|
        expect(cache.csv_path).not_to eq(raw.csv_path)
        expect(cache.digest).to eq(raw.digest)
      end
    end
  end
end
