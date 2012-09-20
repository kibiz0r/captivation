require 'spec_helper'

describe Captivation::Channel do
  it "is its doppleganger's doppleganger" do
    subject.doppleganger.doppleganger.should == subject
  end

  it "pushes a value to its doppleganger" do
    expect do |b|
      subject.doppleganger.each &b
      subject << 5
    end.to yield_with_args(5)
  end

  it "receives a value from its doppleganger" do
    expect do |b|
      subject.each &b
      subject.doppleganger << 5
    end.to yield_with_args(5)
  end

  context "when initialized with a broadcaster" do
    let :my_broadcaster do
      Reactr::Streamer.new
    end

    subject do
      described_class.new my_broadcaster
    end

    it "forwards broadcasts" do
      expect do |b|
        subject.doppleganger.each &b
        my_broadcaster << 5
      end.to yield_with_args(5)
    end
  end

  context "when initialized with a subscriber" do
    let :my_subscriber do
      Reactr::Streamer.new
    end

    subject do
      described_class.new nil, my_subscriber
    end

    it "forwards subscriptions" do
      expect do |b|
        my_subscriber.each &b
        subject.doppleganger << 5
      end.to yield_with_args(5)
    end
  end

  context "when initialized with both a broadcaster and a subscriber" do
    let :my_broadcaster do
      Reactr::Streamer.new
    end

    let :my_subscriber do
      Reactr::Streamer.new
    end

    subject do
      described_class.new my_broadcaster, my_subscriber
    end

    describe "acting as the channel's doppleganger" do
      it "sends broadcasts to the channel" do
        expect do |b|
          subject.each &b
          my_broadcaster << 5
        end.to yield_with_args(5)
      end

      it "subscribes to broadcasts from the channel" do
        expect do |b|
          my_subscriber.each &b
          subject << 5
        end.to yield_with_args(5)
      end
    end
  end

  context "when connected to another channel" do
    let :other_channel do
      described_class.new
    end

    subject do
      described_class.new.tap do |channel|
        channel.connect other_channel
      end
    end

    it "passes through values" do
      expect do |b|
        subject.doppleganger.each &b
        other_channel.doppleganger << 5
      end.to yield_with_args(5)
    end

    context "with explicit handlers on either side" do
      let! :other_broadcaster do
        Reactr::Streamer.new
      end

      let! :other_subscriber do
        Reactr::Streamer.new
      end

      let! :other_channel do
        described_class.new other_broadcaster, other_subscriber
      end

      let! :my_broadcaster do
        Reactr::Streamer.new
      end

      let! :my_subscriber do
        Reactr::Streamer.new
      end

      before do
        @subject = described_class.new(my_broadcaster, my_subscriber).tap do |channel|
          channel.connect other_channel
        end
      end

      subject { @subject }

      it "passes through values" do
        expect do |b|
          my_subscriber.each &b
          other_broadcaster << 5
        end.to yield_with_args(5)
      end
    end
  end
end
