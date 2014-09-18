require 'zipdekure'

namespace :csv do
  desc "CSVデータをダウンロードし、インポートします。"
  task :import do
    Zipdekure::CSV::KenALL.open(false) do |csv|
      if csv.cache
        puts "ken_all.csv(#{csv.digest})をキャッシュしました。\n"
      else
        puts "ken_all.csvをキャッシュできませんでした。\n"
      end
    end

    Zipdekure::CSV::Jigyosyo.open(false) do |csv|
      if csv.cache
        puts "jigyosyo.csv(#{csv.digest})をキャッシュしました。\n"
      else
        puts "jigyosyo.csvをキャッシュできませんでした。\n"
      end
    end
  end
end
