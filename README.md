# Serial

Serial is a serialization library. Its primary purpose is to generate simple
datastructures from object graphs.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'serial'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install serial

## Usage

You can set up your serializers like this:

``` ruby
# app/serializers/person_serializer.rb
PersonSerializer = Serializer.new do |h, person|
  h.attribute(:id, person.id)
  h.attribute(:name, person.name)
end

# app/serializers/project_serializer.rb
ProjectSerializer = Serializer.new do |h, project|
  h.attribute(:id, project.id)
  h.attribute(:project_name, project.name)
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
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/elabs/serial. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
