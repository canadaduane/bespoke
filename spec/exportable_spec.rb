require_relative 'spec_helper'
require 'logger'
require 'stringio'

describe Bespoke::Exportable do
  let(:logger) { nil }
  let(:export) { Bespoke::Exportable.new(:test, logger) }
  let(:test_data) {
    {
      1 => {:one => 1, :two => 2},
      2 => {:one => 5, :two => 10}
    }
  }

  before do
    export.field(:column, "{{test.one}}-{{test.two}}")
  end

  it "initializes" do
    export
  end

  it "exports templated rows" do
    data = export.export(:test => test_data)
    data.should == [["1-2"], ["5-10"]]
  end

  context "helper methods" do
    it "can be declared" do
      export.field(:helped, "{{helper.helper_method}}")
      export.helper(:helper_method) { |row| "help!" }

      data = export.export(:test => test_data)
      data.should == [["1-2", "help!"], ["5-10", "help!"]]
    end

    it "has access to row data" do
      export.field(:helped, "{{helper.fallback}}")
      export.helper(:fallback) do |row|
        row[:test][:one] || row[:test][:two]
      end

      data = export.export(:test =>
        {
          1 => {:two => 2},
          2 => {:one => 5, :two => 10}
        }
      )
      data.should == [["-2", "2"], ["5-10", "5"]]
    end
  end

  context "logging" do
    let(:output) { StringIO.new }
    let(:logger) { Logger.new(output) }

    it "logs missing join data" do
      export.field(:column, "{{test.id}}-{{test.value}}")
      export.join(:user, :id)
      data = export.export({
        :user => {
          1 => {:test_id => 1, :name => "Duane"},
          2 => {:test_id => 2, :name => "Ken"},
        },
        :test => {
          1 => {:id => 1, :value => 2},
          2 => {:id => 5, :value => 10}
        }
      })
      log_msg = output.string.split(' : ')[1]
      log_msg.should == "Expected foreign key id with value 5 in table user ({:id=>5, :value=>10})\n"
    end
  end
end