require 'spec_helper'
require 'ostruct'

kim = OpenStruct.new({ id: 1, name: "Kim" })
jonas = OpenStruct.new({ id: 2, name: "Jonas" })
project = OpenStruct.new({
  id: 13,
  name: "ProjectPuzzle",
  description: "ProjectPuzzle is our own product",
  client: OpenStruct.new({
    id: 5,
    name: "Elabs AB"
  }),
  people: [kim, jonas],
  assignments: [
    OpenStruct.new({ id: 1, duration: "forever", person: kim }),
    OpenStruct.new({ id: 2, duration: "forever ever", person: jonas }),
  ]
})

class MyContext
  def uppercase(value)
    value.to_s.upcase
  end
end

# app/serializers/person_serializer.rb
PersonSerializer = Serial::Serializer.new do |h, person|
  h.attribute(:id, person.id)
  h.attribute(:name, uppercase(person.name))
end

# app/serializers/project_serializer.rb
ProjectSerializer = Serial::Serializer.new do |h, project|
  h.attribute(:id, project.id)
  h.attribute(:projectName, uppercase(project.name))
  h.attribute(:description, project.description)

  h.attribute(:client, project.client) do |h, client|
    h.attribute(:id, client.id)
    h.attribute(:name, client.name)
  end

  h.map(:people, project.people, &PersonSerializer)

  h.map(:assignments, project.assignments) do |h, assignment|
    h.attribute(:id, assignment.id)
    h.attribute(:duration, assignment.duration)

    h.attribute(:person, assignment.person, &PersonSerializer)
  end
end

describe Serial do
  it 'has a version number' do
    expect(Serial::VERSION).not_to be nil
  end

  def prefix(value)
    "Mr. #{value}"
  end

  it 'works without context object' do
    # app/serializers/person_serializer.rb
    person_serializer = Serial::Serializer.new do |h, person|
      h.attribute(:id, person.id)
      h.attribute(:name, prefix(person.name))
    end

    full_person_serializer = Serial::Serializer.new do |h, person|
      h.attribute(:id, person.id)
      h.attribute(:name, prefix(person.name))
      h.attribute(:friend, jonas, &person_serializer)
    end

    expect(full_person_serializer.call(kim)).to eq({
      "id" => 1,
      "name" => "Mr. Kim",
      "friend" => {
        "id" => 2,
        "name" => "Mr. Jonas",
      }
    })
  end

  it 'works with context object' do
    expect(ProjectSerializer.call(MyContext.new, project)).to eq({
      "id" => 13,
      "projectName" => "PROJECTPUZZLE",
      "description" => "ProjectPuzzle is our own product",
      "client" => {
        "id" => 5,
        "name" => "Elabs AB"
      },
      "people" => [
        {
          "id" => 1,
          "name" => "KIM"
        },
        {
          "id" => 2,
          "name" => "JONAS"
        }
      ],
      "assignments" => [
        {
          "id" => 1,
          "duration" => "forever",
          "person" => {
            "id" => 1,
            "name" => "KIM"
          }
        },
        {
          "id" => 2,
          "duration" => "forever ever",
          "person" => {
            "id" => 2,
            "name" => "JONAS"
          }
        }
      ]
    })
  end
end
