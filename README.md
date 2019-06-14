# Hyp
Hyp is in über ultra beta! It is not production ready. We're still working out
the kinks. Capiche?

Easily run, monitor, and understand A/B tests from your Rails app.

Hyp lets you A/B test any part of your Ruby on Rails application! Test email
content, algorithms, server-rendered pages, or anything else you like.

Both ActiveRecord- and Mongoid-backed applications are supported.

## Table of Contents
1. [Basic Usage](#basic-usage)
2. [Installation and Configuration](#installation-and-configuration)
3. [Get notified upon completion of an experiment](#get-notified-upon-completion-of-an-experiment)
4. [API](#api)
5. [Contributing](#contributing)
6. [License](#license)

## Basic Usage
Conditionally execute code based on the experiment alternative a user belongs to:
```ruby
experiment  = Hyp::Experiment.find_by(name: 'My very first experiment')
alternative = experiment.alternative_for(user)

if alternative.control?
  # do existing behavior
else
  # do new behavior
end
```

Record user trials and conversions via Ruby:
```ruby
# Eg, when user visits a page
experiment = Hyp::Experiment.find_by(name: 'My very first experiment')
experiment.record_trial(user)

# Eg, when user takes the action you're interested in
experiment.record_conversion(user)

# Or, all in one go
experiment.record_trial_and_conversion(user)
```

Or via JavaScript:
```javascript
$.post(
  '/hyp/experiment_user_trials',
  { experiment_name: 'My Very First Experiment', user_identifier: 1 },
  function(data, status, _xhr) { console.log("Status: %s\nData: %s", status, data); }
);
```

Visit the `/hyp/experients` page to CRUD your experiments:

Click on a particular experiment to see how far along it is, and what conclusions
can be drawn from it (if any):

## Installation and Configuration
Add this line to your application's Gemfile:

```ruby
gem 'hyp'
```

And then run:
```bash
$ bundle
```

Finally, run the installation generator:
```bash
$ rails g hyp:install
```

This will:
+ Create `config/initializers/hyp.rb`.
+ Add `mount Hyp::Engine => '/hyp'` to the top of your `config/routes.rb` file.
+ Add the migrations for creating Hyp's database tables to your `db/migrate` directory.

`hyp:install` takes two optional flags: `--db-interface`, and `--user-class`.

`--db-interface` tells Hyp which ORM/ODM your application uses. It can be either `active_record` or `mongoid`. It defaults to `active_record` if not present.

`--user-class` tells Hyp what class you'd like to use as the "user" or "actor"
in your experiments. It can be any string that can be `#constantize`'d to a valid
class from your application code. It defaults to `'User'` if not present.

If you add `--db-interface mongoid` the generator will:
+ Add `Hyp.db_interface = :mongoid` to `config/initializers/hyp.rb`.
+ Not add the aforementioned migrations.
+ Create models that know how to talk to Mongoid. Hooray!

If you add `--user-class 'MyClass'` the generator will add
`Hyp.user_class_name = 'MyClass'` to `config/initializers/hyp.rb`.

## Get notified upon completion of an experiment
Hyp lets you run arbitrary code upon completion of an experiment. For example
you may want to kick off a background job that will send you an email when an
experiment finds a significant result.

To set this up open `config/initializers/hyp.rb` and set
`Hyp.experiment_complete_callback` to an object that responds to `#call` (such
  as a lambda) and expects a single argument. Eg:

For example:
```ruby
Hyp.experiment_complete_callback = ->(experiment_id) {
  experiment = Hyp::Experiment.find(experiment_id)
  puts experiment.winner.name
}
```

## API
Full API documentation coming soon!

## Contributing
Contributions are most welcome, but remember: You're required to be nice to others! It's the law!

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
