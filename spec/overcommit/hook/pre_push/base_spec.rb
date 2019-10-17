# frozen_string_literal: true

require 'spec_helper'

describe Overcommit::Hook::PrePush::Base do
  let(:remote_name) { 'origin' }
  let(:remote_branch_deletion?) { false }
  let(:config) { double('config') }
  let(:context) { double('context') }
  let(:hook) { described_class.new(config, context) }

  describe '#run?' do
    let(:hook_config) { {} }

    before do
      allow(context).to receive(:remote_name).and_return(remote_name)
      allow(context).to receive(:remote_branch_deletion?).and_return(remote_branch_deletion?)
      allow(config).to receive(:for_hook).and_return(hook_config)
    end

    subject { hook.run? }

    context 'with exclude_remotes specified' do
      let(:hook_config) do
        { 'exclude_remotes' => exclude_remotes }
      end

      context 'exclude_remotes is nil' do
        let(:exclude_remotes) { nil }

        it { subject.should == true }
      end

      context 'exclude_remotes includes the remote' do
        let(:exclude_remotes) { [remote_name] }

        it { subject.should == false }
      end

      context 'exclude_remotes does not include the remote' do
        let(:exclude_remotes) { ['heroku'] }

        it { subject.should == true }
      end
    end

    context 'with include_branch_deletions specified' do
      let(:hook_config) do
        { 'include_branch_deletions' => include_branch_deletions }
      end
      let(:remote_branch_deletion?) { false }
      let(:include_branch_deletions) { false }

      context 'when remote branch is not being deleted' do
        let(:remote_branch_deletion?) { false }

        context 'when include_branch_deletions is not specified' do
          let(:include_branch_deletions) { nil }

          it { subject.should == true }
        end

        context 'when include_branch_deletions is false' do
          let(:include_branch_deletions) { false }

          it { subject.should == true }
        end

        context 'when include_branch_deletions is true' do
          let(:include_branch_deletions) { true }

          it { subject.should == true }
        end
      end

      context 'when remote branch is being deleted' do
        let(:remote_branch_deletion?) { true }

        context 'when include_branch_deletions is not specified' do
          let(:include_branch_deletions) { nil }

          it { subject.should == false }
        end

        context 'when include_branch_deletions is false' do
          let(:include_branch_deletions) { false }

          it { subject.should == false }
        end

        context 'when include_branch_deletions is true' do
          let(:include_branch_deletions) { true }

          it { subject.should == true }
        end
      end
    end
  end
end
