require_relative 'spec_helper'

describe Bespoke::Exportable do
  let(:export) { Bespoke::Exportable.new(:test) }

  it "initializes" do
    Bespoke::Exportable.new(:test)
  end

  it "exports templated rows" do
    export.field(:column, "{{test.one}}-{{test.two}}")
    data = export.export({:test => {
      1 => {:one => 1, :two => 2},
      2 => {:one => 5, :two => 10}
    }})
    data.should == [["1-2"], ["5-10"]]
  end
end