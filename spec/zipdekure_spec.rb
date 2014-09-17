require 'spec_helper'

describe Zipdekure do
  describe Zipdekure::ROOT_DIR do
    it '正しいルートディレクトリを返すこと' do
      expect(File.exists?(File.join(Zipdekure::ROOT_DIR, 'lib', 'zipdekure.rb'))).to be_truthy
    end
  end
end
