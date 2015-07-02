require 'spec_helper'


describe SupportRotaDoc  do

  describe '#names_matching' do
    context 'invalid period' do
      it 'should throw exception' do
        srd = SupportRotaDoc.default
        expect {
          srd.devs(:invalid_period)
        }.to raise_error ArgumentError, 'period must be either :current or :next'
      end
    end
  end
end