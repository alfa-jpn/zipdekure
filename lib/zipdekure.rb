require "zipdekure/version"
require "zipdekure/address"
require "zipdekure/csv/base"
require "zipdekure/csv/ken_all"
require "zipdekure/csv/jigyosyo"
require "zipdekure/parsers/base"
require "zipdekure/parsers/ken_all"
require "zipdekure/parsers/jigyosyo"

module Zipdekure
  ROOT_DIR = Gem::Specification.find_by_name('zipdekure').gem_dir
  TMP_DIR  = File.join(ROOT_DIR, 'temp')
end
