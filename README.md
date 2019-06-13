# Beta
Hyp is in über ultra beta! It is not production ready. We're still working out
the kinks. Capiche?

# Hyp
Easily run, monitor, and understand A/B tests from your Rails app.

Hyp lets you A/B test way more than UI changes on static pages! Test email content,
algorithms, dynamic pages, or anything else in your Ruby or JavaScript code.

Both ActiveRecord- and Mongoid-backed applications are supported.

## Usage
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
experiment  = Hyp::Experiment.find_by(name: 'My very first experiment')
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

## Installation
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

`hyp:install` takes an optional `--db-interface` flag, which can be either
`active_record` or `mongoid`. It defaults to `active_record` if not present.

If you add `--db-interface mongoid` the generator will:
+ Add `Hyp.db_interface = :mongoid` to `config/initializers/hyp.rb`.
+ Not add the aforementioned migrations.
+ Create models that know how to talk to Mongoid. Hooray!

## Contributing
Contributions are most welcome, but remember: You're required to be nice to others! It's the law!

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
