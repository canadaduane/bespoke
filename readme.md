Bespoke
=======

Getting Started
---------------

```ruby
config = {
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
          },
          "joins" => {
            "school" => "school_id"
          }
        }
      }
    ]
  }
}

data = {
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

bespoke = Bespoke.new(config)

data.each_pair do |type, rows|
  rows.each do |row|
    bespoke.add type, row
  end
end

rows = []
bespoke.export("users") do |row|
  rows << row
end

# rows:
#  ["1", "Eric Adams"]
#  ["2", "Duane Johnson"]
#  ["3", "Ken Romney"]
#  ["1", "North Professor Baxter"]
#  ["2", "East Professor Summer"]

```

DSL
---

Note that there is also an easy-to-use DSL if you don't want to use a json config. Use ```indexed_collection``` to declare an IndexedCollection and ```exportable``` to declare an Exportable.

```ruby
require 'bespoke/dsl'

indexed = indexed_collection do
  index :student,   :id
  index :staff,     :id
  index :school,    :id
end

exports = {
  users: [
    exportable(:student) {
      field :user_id, "{{student.id}}"
      field :name,    "{{student.first_name}} {{student.last_name}}"
    },
    exportable(:staff) {
      field :user_id, "{{staff.id}}"
      field :name,    "{{school.district}} Professor {{staff.last_name}}"
    }
  ],
  schools: [
    exportable(:school) {
      field :school_id, "{{school.id}}"
      field :district,  "D:{{school.district}}"

      join :school, :school_id
    }
  ]
}
```
