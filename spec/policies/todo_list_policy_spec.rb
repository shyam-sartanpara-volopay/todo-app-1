require 'rails_helper'

RSpec.describe TodoListPolicy, type: :policy do
  subject { described_class.new(user, todo_list) }

  let(:user) { create(:user) }
  let(:collaborator) { create(:user) }
  let(:other_user) { create(:user) }
  let(:todo_list) { create(:todo_list, user: user) }

  before do
    create(:collaboration, user: collaborator, todo_list: todo_list)
  end


  describe "#index?" do
    context "when user is authenticated" do
      it { expect(described_class.new(user, todo_list).index?).to be true }
    end

    context "when user is a collaborator" do
      it { expect(described_class.new(collaborator, todo_list).index?).to be true }
    end

    context "when user is neither owner nor collaborator" do
      it { expect(described_class.new(other_user, todo_list).index?).to be false }
    end
  end


  describe "#show?" do
    context "when user is the owner" do
      it { expect(subject.show?).to be true }
    end

    context "when user is a collaborator" do
      it { expect(described_class.new(collaborator, todo_list).show?).to be true }
    end

    context "when user is neither owner nor collaborator" do
      it { expect(described_class.new(other_user, todo_list).show?).to be false }
    end
  end

  describe "#update?" do
    context "when user is the owner" do
      it { expect(subject.update?).to be true }
    end

    context "when user is not the owner" do
      it { expect(described_class.new(collaborator, todo_list).update?).to be false }
    end
  end

  describe "#destroy?" do
    context "when user is the owner" do
      it { expect(subject.destroy?).to be true }
    end

    context "when user is not the owner" do
      it { expect(described_class.new(collaborator, todo_list).destroy?).to be false }
    end
  end
end
