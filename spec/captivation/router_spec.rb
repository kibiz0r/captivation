require 'spec_helper'

describe Captivation::Router do
  describe "the public channel" do
    it "receives messages from the private channel" do
      expect do |b|
        subject.public_channel.each &b
        subject.private_channel << ["a message", "an arg"]
      end.to yield_with_args(["a message", "an arg"])
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
end
