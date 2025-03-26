require 'rails_helper'

RSpec.describe CollaborationPolicy, type: :policy do
  subject { described_class.new(user, collaboration) }

  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:todo_list) { create(:todo_list, user: user) }
  let(:collaboration) { create(:collaboration, todo_list: todo_list, user: other_user) }

  describe "#index?" do
    context "when user is the owner" do
      it { expect(subject.index?).to be true }
    end

    context "when user is not the owner" do
      it { expect(described_class.new(other_user, collaboration).index?).to be false }
    end
  end

  describe "#show?" do
    context "when user is the owner" do
      it { expect(subject.show?).to be true }
    end

    context "when user is a collaborator" do
      it { expect(described_class.new(other_user, collaboration).show?).to be false }
    end

    context "when user is neither the owner nor a collaborator" do
      let(:random_user) { create(:user) }
      it { expect(described_class.new(random_user, collaboration).show?).to be false }
    end
  end

  describe "#create?" do
    context "when user is the owner of the todo list" do
      it { expect(subject.create?).to be true }
    end

    context "when user is not the owner" do
      it { expect(described_class.new(other_user, collaboration).create?).to be false }
    end
  end

  describe "#update?" do
    context "when user is the owner" do
      it { expect(subject.update?).to be true }
    end

    context "when user is not the owner" do
      it { expect(described_class.new(other_user, collaboration).update?).to be false }
    end
  end

  describe "#destroy?" do
    context "when user is the owner" do
      it { expect(subject.destroy?).to be true }
    end

    context "when user is not the owner" do
      it { expect(described_class.new(other_user, collaboration).destroy?).to be false }
    end
  end
end
