require 'spec_helper'

describe HipchatWebhook do


  describe '#process' do
    
    context 'problem on' do
      it 'should create a hipchat problem mode flag' do
        expect(Flag).to receive(:create).with('hipchat:problem_mode')
        webhook = HipchatWebhook.new('room' => '2nd_line', 'message' => 'problem on')
        webhook.process
      end
    end

    context 'problem off' do
      it 'should destroy a hipchat problem mode flag' do
        expect(Flag).to receive(:destroy).with('hipchat:problem_mode')
        webhook = HipchatWebhook.new('room' => '2nd_line', 'message' => 'problem off')
        webhook.process
      end
    end
  end
end
