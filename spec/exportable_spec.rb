require_relative 'spec_helper'
require 'logger'
require 'stringio'

describe Bespoke::Exportable do
  let(:logger) { nil }
  let(:export) { Bespoke::Exportable.new(:test, logger) }

  it "initializes" do
    export
  end

  it "exports templated rows" do
    export.field(:column, "{{test.one}}-{{test.two}}")
    data = export.export({:test => {
      1 => {:one => 1, :two => 2},
      2 => {:one => 5, :two => 10}
    }})
    data.should == [["1-2"], ["5-10"]]
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