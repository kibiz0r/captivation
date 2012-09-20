require 'spec_helper'

describe Captivation::Router do
  describe "the public channel" do
    it "receives messages from the private channel" do
      expect do |b|
        subject.public_channel.each &b
        subject.private_channel << ["a message", "an arg", "another"]
      end.to yield_with_args(["a message", "an arg", "another"])
    end

    it "can be blocked from receiving messages from the private channel" do
      subject.block
      expect do |b|
        subject.public_channel.each &b
        subject.private_channel << ["never"]
      end.not_to yield_control
    end

    it "posts messages to the private channel" do
      expect do |b|
        subject.private_channel.each &b
        subject.public_channel << ["some message"]
      end.to yield_with_args(["some message"])
    end

    it "can be denied messages posted to the public channel" do
      subject.deny
      expect do |b|
        subject.private_channel.each &b
        subject.public_channel << ["never"]
      end.not_to yield_control
    end

    it "doesn't receive the message it sends" do
      expect do |b|
        subject.public_channel.each &b
        subject.public_channel << ["never"]
      end.not_to yield_control
    end
  end

  describe "the private channel" do
    it "doesn't receive the message it sends" do
      expect do |b|
        subject.private_channel.each &b
        subject.private_channel << ["never"]
      end.not_to yield_control
    end
  end

  describe "a named channel" do
    it "posts messages to the private channel" do
      expect do |b|
        subject.private_channel.each &b
        subject.named_channel(:foo) << ["something"]
      end.to yield_with_args(["something"])
    end

    it "posts messages to the public channel" do
      expect do |b|
        subject.public_channel.each &b
        subject.named_channel(:foo) << ["something"]
      end.to yield_with_args(["something"])
    end

    context "when ignored" do
      it "cannot post messages to the private channel" do
        subject.ignore "something"
        expect do |b|
          subject.private_channel.each &b
          subject.named_channel(:foo) << ["something"]
        end.not_to yield_control
      end

      it "cannot post messages to the public channel" do
        subject.ignore "something"
        expect do |b|
          subject.public_channel.each &b
          subject.named_channel(:foo) << ["something"]
        end.not_to yield_control
      end
    end
  end

  context "with a child router" do
    let :child_router do
      described_class.new
    end

    subject do
      described_class.new.tap do |router|
        router.named_channel(:foo).subscribe child_router.public_channel
        child_router.public_channel.subscribe router.named_channel(:foo)
      end
    end

    it "shares the child's public messages across a named channel to its own private channel" do
      expect do |b|
        subject.private_channel.each &b
        child_router.private_channel << [5]
      end.to yield_with_args([5])
    end

    it "shares private messages across a named channel to the child's private channel" do
      subject.share :foo
      expect do |b|
        child_router.private_channel.each &b
        subject.private_channel << [5]
      end.to yield_with_args([5])
    end
  end
end
