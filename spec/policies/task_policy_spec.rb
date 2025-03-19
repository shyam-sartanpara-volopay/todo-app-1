require 'rails_helper'

RSpec.describe TaskPolicy, type: :policy do
  let(:user) { create(:user) }
  let(:collaborator) { create(:user) }
  let(:other_user) { create(:user) }
  let(:todo_list) { create(:todo_list, user: user) }
  let(:task) { create(:task, todo_list: todo_list) }
  let(:policy) { described_class.new(user, task) }

  before do
    create(:collaboration, user: collaborator, todo_list: todo_list)
  end

  shared_examples 'grants access' do
    it { expect(policy.send(action)).to be true }
  end

  shared_examples 'denies access' do
    it { expect(policy.send(action)).to be false }
  end

  describe "#show?" do
    let(:action) { :show? }

    context "when user is the owner" do
      include_examples 'grants access'
    end

    context "when user is a collaborator" do
      let(:policy) { described_class.new(collaborator, task) }
      include_examples 'grants access'
    end

    context "when user is neither owner nor collaborator" do
      let(:policy) { described_class.new(other_user, task) }
      include_examples 'denies access'
    end
  end

  describe "#create?" do
    let(:action) { :create? }
    let(:new_task) { build(:task, todo_list: todo_list) } # ✅ Use `build` instead of `create`

    context "when user is the owner" do
      let(:policy) { described_class.new(user, new_task) }
      include_examples 'grants access'
    end

    context "when user is a collaborator" do
      let(:policy) { described_class.new(collaborator, new_task) }
      include_examples 'grants access'
    end

    context "when user is neither owner nor collaborator" do
      let(:policy) { described_class.new(other_user, new_task) }
      include_examples 'denies access'
    end
  end

  describe "#update?" do
    let(:action) { :update? }

    context "when user is the owner" do
      include_examples 'grants access'
    end

    context "when user is a collaborator" do
      let(:policy) { described_class.new(collaborator, task) }
      include_examples 'grants access'
    end

    context "when user is neither owner nor collaborator" do
      let(:policy) { described_class.new(other_user, task) }
      include_examples 'denies access'
    end
  end

  describe "#destroy?" do
    context "when user is the owner" do
      it { expect(policy.destroy?).to be true }
    end

    context "when user is a collaborator" do
      let(:policy) { described_class.new(collaborator, task) }
      it { expect(policy.destroy?).to be false }
    end

    context "when user is neither owner nor collaborator" do
      let(:policy) { described_class.new(other_user, task) }
      it { expect(policy.destroy?).to be false }
    end
  end
end
