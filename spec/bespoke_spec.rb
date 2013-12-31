require_relative 'spec_helper'

describe Bespoke do
  let(:data) {
    {
      "student" => [
        { "id" => 1, "first_name" => "Eric",  "last_name" => "Adams" },
        { "id" => 2, "first_name" => "Duane", "last_name" => "Johnson" },
        { "id" => 3, "first_name" => "Ken",   "last_name" => "Romney" }
      ],
      "staff" => [
        { "id" => 1, "last_name" => "Baxter", "school_id" => 1 },
        { "id" => 2, "last_name" => "Summer", "school_id" => 2 }
      ],
      "school" => [
        { "id" => 1, "district" => "North" },
        { "id" => 2, "district" => "East" },
        { "id" => 3, "district" => "South" }
      ]
    }
  }
  let(:config) {
    {
      "index" => {
        "student" => ["id"],
        "staff"   => ["id"],
        "school"  => ["id"]
      },
      "export" => {
        "users" => [
          {
            "student" => {
              "fields" => {
                "user_id" => "{{student.id}}",
                "name"    => "{{student.first_name}} {{student.last_name}}"
              }
            }
          },
          {
            "staff" => {
              "fields" => {
                "user_id" => "{{staff.id}}",
                "name"    => "{{school.district}} Professor {{staff.last_name}}"
              },
              "joins" => {
                "school" => "school_id"
              }
            }
          }
        ],
        "schools" => [
          {
            "school" => {
              "fields" => {
                "school_id" => "{{school.id}}",
                "district"  => "D:{{school.district}}"
              }
            }
          }
        ]
      }
    }
  }
  let(:bespoke) { Bespoke.new(config) }

  it "initializes" do
    Bespoke.new(config)
  end

  context "with loaded data" do
    before do
      data.each_pair do |type, rows|
        rows.each do |row|
          bespoke.add type, row
        end
      end
    end

    it "creates a collection in memory" do
      bespoke.collection.collections.should == {
        :student => {
          1 => {"id"=>1, "first_name"=>"Eric", "last_name"=>"Adams"},
          2 => {"id"=>2, "first_name"=>"Duane", "last_name"=>"Johnson"},
          3 => {"id"=>3, "first_name"=>"Ken", "last_name"=>"Romney"}
        },
        :staff => {
          1 => {"id"=>1, "last_name"=>"Baxter", "school_id"=>1},
          2 => {"id"=>2, "last_name"=>"Summer", "school_id"=>2}
        },
        :school => {
          1 => {"id"=>1, "district"=>"North"},
          2 => {"id"=>2, "district"=>"East"},
          3 => {"id"=>3, "district"=>"South"}
        }
      }
    end

    it "exports" do
      rows = []
      bespoke.export("users") do |row|
        rows << row
      end
      rows.should == [
        ["1", "Eric Adams"],
        ["2", "Duane Johnson"],
        ["3", "Ken Romney"],
        ["1", "North Professor Baxter"],
        ["2", "East Professor Summer"]
      ]
    end
  end
end