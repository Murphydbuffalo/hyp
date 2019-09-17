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
4. [Authorization](#authorization)
5. [The Math](#the-math)
6. [API](#api)
7. [Contributing](#contributing)
8. [License](#license)

## Basic Usage
Hyp requires two things from your application to start running experiments:
1. Unique identifiers for the users in your application.
2. An existing conversion rate for the feature you want to experiment with. This
is needed to calculate the required sample size for the experiment (more on that
in the [Math](#math) section if you're curious.)

Given those things you're ready to run some experiments!

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

User assignments are consistent, so a given user will always belong to the same
alternative for a given experiment. The assignments are based on a SHA256 hash
of both the user's and experiment's `#id`. *This means that your user entities
must provide a unique identifier.*

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

Visit the `/hyp/experiments` page to CRUD your experiments:

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

In Hyp we associate each trial with a particular user using a "has and belongs
to many" relationships between the user and experiment. The `--user-class` option tells Hyp what class you'd like to use as the "user" in your experiments.
It can be any string that can be `#constantize`'d to a valid class from your application code. It defaults to `'User'` if not present.

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

## Authorization
Hyp runs HTTP Basic Auth on the `ExperimentsController` in the production environment. Be sure to set the `HYP_USERNAME` and `HYP_PASSWORD`
environment variables, which will be the credentials required to log in.

## The Math
Coming soon!

## API
### `Hyp::Experiment`
#### Associations
+ `has_many` `Hyp::Alternative`s, an experiment will always have two alternatives.
When an experiment is destroyed so are its dependent alternatives.
+ `has_many` `Hyp::ExperimentUserTrial`s. When an experiment is destroyed so are
its dependent user trials.

#### Database scopes
-

#### Database fields
+ `#alpha` - the significance level of the experiment. A float that is either 0.05 or 0.01.                    
+ `#control` - the conversion rate of the existing alternative of the feature. A float between 0.0 and 1.0.
+ `#created_at` - Timestamp
+ `#minimum_detectable_effect` - the minimum detectable effect (MDE) of the
experiment. This is the smallest effect size you care about. A float between 0.0 and 1.0.
+ `#name` - the name of the experiment, a string.                      
+ `#power` - the statistical power of the experiment. A float that is either 0.80 or 0.90.                    
+ `#updated_at` - Timestamp

#### Callbacks
-

#### Instance methods
+ `#alternative_name(user)` - Returns the name of the alternative a user belongs to for the experiment. The alternative for a given experiment and user will always be the same.
+ `#approximate_percent_finished` - Percentage approximation of the proportion of
trials recorded versus the required sample size of the experiment.
+ `#control_conversion_rate` - The proportion of users who have been exposed to
the control alternative that have converted.
+ `#effect_size` - The difference between the control and treatment conversion rates. A float.
+ `#finished?` - Has the experiment recorded `#sample_size` trials for each alternative? Finished experiments cannot have any more trials or conversions
recorded.
+ `#loser` - Returns `nil` if the experiment is not `finished?` or if no significant result was found. Otherwise returns the losing alternative.
+ `#record_conversion(user)` - Finds or creates a trial for the user and experiment (represented as an `ExperimentUserTrial` in the database) with the `converted` field set to `true`.
+ `#record_trial(user)` - Finds or creates a trial for the user and experiment (represented as an `ExperimentUserTrial` in the database).
+ `#running?` - Has the experiment `#started?` but not `#finished?`
+ `#sample_size` - The number of trials *per alternative* required to reach statistical significance for the experiment's `#power` and `#minimum_detectable_effect`. A positive integer.
+ `#significant_result_found?` - Is the result statistically significant?
+ `#started?` - Have any trials been recorded for the experiment? Experiments that have started cannot be edited.
+ `#treatment_conversion_rate` - The proportion of users who have been exposed to
the treatment alternative that have converted.
+ `#winner` - Returns `nil` if the experiment is not `finished?` or if no significant result was found. Otherwise returns the winning alternative.

### `Hyp::Alternative`
#### Associations
+ `belongs_to` a `Hyp::Experiment`, which will always have two alternatives.
+ `has_many` `Hyp::ExperimentUserTrial`s.

#### Database scopes
+ `.control` - Database scope that queries for control alternatives.
+ `.treatment` - Database scope that queries for treatment alternatives.

#### Database fields
+ `#created_at` - Timestamp
+ `#name` - The name of the alternative, either `'control'`, or `'treatment'`.
+ `#updated_at` - Timestamp

#### Callbacks
-

#### Instance methods
+ `#control?` - Is this the control alternative, the existing version of the
feature that currently exists in your app?
+ `#treatment?` - Is this the treatment alternative, the new version of the
feature that you'd like to compare to the control?

### `Hyp::ExperimentUserTrial`
#### Associations
+ `belongs_to` a `Hyp::Experiment`.
+ `belongs_to` a `Hyp::Alternative`.
+ `belongs_to` a `User` (or whatever the result of `#constantize`ing `Hyp.user_class_name` is).

#### Database scopes
-

#### Database fields
+ `converted` - Boolean, defaults to `false`.

#### Callbacks
+ `after_create` - If you've set `Hyp.experiment_complete_callback` to an object that responds to `#call` in the `config/intializers/hyp.rb` file that object will have `#call`
invoked with the `#id` of the experiment once it has run to completion.

#### Instance methods
-

## Contributing
Contributions are most welcome, but remember: You're required to be nice to others! It's the law!

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
