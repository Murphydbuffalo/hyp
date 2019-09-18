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
5. [Methodology](#methodology)
6. [API](#api)
7. [Testing](#testing)
8. [Contributing](#contributing)
9. [License](#license)

## Basic Usage
Hyp requires two things from your application to start running experiments:
1. Unique identifiers for the users in your application.
2. An existing conversion rate for the feature you want to experiment with. This
is needed to calculate the required sample size for the experiment (more on that
in the [methodology](#methodology) section if you're curious.)

Given those things you're ready to run some experiments!

Conditionally execute code based on the experiment variant a user belongs to:
```ruby
experiment  = Hyp::Experiment.find_by(name: 'My very first experiment')
variant = experiment.variant_for(user)

if variant.control?
  # do existing behavior
else
  # do new behavior
end
```

User assignments are consistent, so a given user will always belong to the same
variant for a given experiment. The assignments are based on a SHA256 hash
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
Hyp runs HTTP Basic Auth on the `ExperimentsController` in the production and staging environments. Be sure to set the `HYP_USERNAME` and `HYP_PASSWORD` environment variables, which will be the credentials required to log in.

## Methodology
Hyp runs two-tailed hypothesis tests for the difference of two sample
proportions: the proportion of users who converted on the control variant of a
feature and the proportion of users who converted on the treatment (new,
experimental) variant of a feature.

Our hypotheses are as follows:
Null hypothesis,      h0: (control - treatment)  = 0
Alternate hypothesis, hA: (control - treatment) != 0

The effect size of the test is the difference between those two proportions.

We calculate a z-score for that effect size, which is how many standard
deviations it is from the mean of a normal distribution.

This standard deviation calculation relies on the size of the sample the
proportions are calculated for, and we determine this sample size prior to the
running the experiment based the values of alpha, statistical power, minimum
detectable effect, and the control proportion you have selected for it.

This sample size is the smallest sample size required *for each variant* so that
you will have your specified level of power given your level alpha, your control
proportion, and an effect size at least as big as your MDE.

Let's look at each of the parameters used to the sample size calculation in more depth:
+ Alpha - Required to be one of two conventional values: 0.05 or 0.01. This is
the probability of a false positive, also known as the significance level.
+ Power - Required to be one of two conventional values: 0.80 or 0.90. This is
the probability of detecting a positive result (rejecting the null hypothesis) if
one is present. Higher power means a lower probability of false negatives (not
rejecting the null hypothesis when it is false).
+ Control proportion - You must have existing data on the conversion rate of the
current variant of the feature. This is the control proportion.
+ Minimum detectable effect - The smallest effect size you would care to detect.
We don't want to run an experiment only to find out that our effect size, although
statistically significant, is not large enough to deliver business value.

For a more in-depth discussion of these parameters and sample size calculations
check out [my blog post on the subject](https://murphydbuffalo.tumblr.com/post/185500662003/why-do-i-need-such-a-large-sample-size-for-my-ab).

Using our z-score we then calculate a p-value, or the probability of an effect
size at least as large as ours occurring by random chance given that the null
hypothesis is true.

If this p-value is is lower than the experiment's level of alpha we have a
statistically significant result.

It is up to you to interpret the the results of the hypothesis test. A higher
treatment conversion rate may be good, signifying a greater percentage of users
who visited a page clicked on the sign up button. It may also be bad, perhaps
signifying that a greater percentage of existing customers clicked the button to
cancel their account.

An experiment might tell you that while the results are significant, it is the
*control* variant that performs better, and therefore that you should not
replace it with the treatment.

Perhaps no significant result will be detected: remember that you only have a
percentage chance of detecting positive results equal to your chosen level of
statistical power.

You might decide to replace the existing variant of the feature even if there is
no statistically significant difference between the two variants simply because
you prefer the code quality or esthetic quality of one variant as the Signal v.
Noise blog points out in [an excellent post on the topic](https://signalvnoise.com/posts/3004-ab-testing-tech-note-determining-sample-size).

## API
### `Hyp::Experiment`
#### Associations
+ `has_many` `Hyp::Variant`s, an experiment will always have two variants.
When an experiment is destroyed so are its dependent variants.
+ `has_many` `Hyp::ExperimentUserTrial`s. When an experiment is destroyed so are
its dependent user trials.

#### Database fields
+ `#alpha` - the significance level of the experiment. A float that is either 0.05 or 0.01.                    
+ `#control` - the conversion rate of the existing variant of the feature. A float between 0.0 and 1.0.
+ `#created_at` - Timestamp
+ `#minimum_detectable_effect` - the minimum detectable effect (MDE) of the
experiment. This is the smallest effect size you care about. A float between 0.0 and 1.0.
+ `#name` - the name of the experiment, a string.                      
+ `#power` - the statistical power of the experiment. A float that is either 0.80 or 0.90.                    
+ `#updated_at` - Timestamp

#### Instance methods
+ `#percent_finished` - What percentage of the required sample size (for all
variants) has been met?
+ `#control_conversion_rate` - The percentage of users who have been exposed to
the control variant that have converted.
+ `#control_variant` - the control instance of `Hyp::Variant` for this experiment.
+ `#effect_size` - The difference between the control and treatment conversion rates. A float.
+ `#finished?` - Has the experiment recorded `#sample_size` trials for each variant? Finished experiments cannot have any more trials or conversions
recorded.
+ `#loser` - Returns `nil` if the experiment is not `finished?` or if no significant result was found. Otherwise returns the losing variant.
+ `#record_conversion(user)` - Finds or creates a trial for the user and experiment (represented as an `ExperimentUserTrial` in the database) with the `converted` field set to `true`.
+ `#record_trial(user)` - Finds or creates a trial for the user and experiment (represented as an `ExperimentUserTrial` in the database).
+ `#sample_size` - The number of trials *per variant* required to reach statistical significance for the experiment's `#power` and `#minimum_detectable_effect`. A positive integer.
+ `#significant_result_found?` - Is the result statistically significant?
+ `#started?` - Have any trials been recorded for the experiment? Experiments that have started cannot be edited.
+ `#treatment_conversion_rate` - The percentage of users who have been exposed to
the treatment variant that have converted.
+ `#treatment_variant` - the treatment instance of `Hyp::Variant` for this experiment.
+ `#winner` - Returns `nil` if the experiment is not `finished?` or if no significant result was found. Otherwise returns the winning variant.

### `Hyp::Variant`
#### Associations
+ `belongs_to` a `Hyp::Experiment`, which will always have two variants.
+ `has_many` `Hyp::ExperimentUserTrial`s.

#### Database scopes
+ `.control` - Database scope that queries for control variants.
+ `.treatment` - Database scope that queries for treatment variants.

#### Database fields
+ `#created_at` - Timestamp
+ `#name` - The name of the variant, either `'control'`, or `'treatment'`.
+ `#updated_at` - Timestamp

#### Instance methods
+ `#control?` - Is this the control variant, the existing variant of the
feature that currently exists in your app?
+ `#treatment?` - Is this the treatment variant, the new variant of the
feature that you'd like to compare to the control?

### `Hyp::ExperimentUserTrial`
#### Associations
+ `belongs_to` a `Hyp::Experiment`.
+ `belongs_to` a `Hyp::Variant`.
+ `belongs_to` a `User` (or whatever the result of `#constantize`ing `Hyp.user_class_name` is).

#### Database fields
+ `converted` - Boolean, defaults to `false`.

#### Callbacks
+ `after_create` - If you've set `Hyp.experiment_complete_callback` to an object that responds to `#call` in the `config/intializers/hyp.rb` file that object will have `#call`
invoked with the `#id` of the experiment once it has run to completion.

## Testing
There are RSpec unit tests for code that doesn't depend on Rails in the `spec`
directory as well as a dummy Rails application under `spec/dummy`.

There are specs for Rails-dependent classes in `spec/dummy/spec`, to run those:
1. `cd spec/dummy`
2. `rspec spec/**/*_spec.rb`

You can also boot up the dummy application to play around with Hyp in the browser.
To. run the dummy app you need to:
1. `cd spec/dummy`
2. `Run a local postgres server`
3. `createdb dummy_development`
4. `cd spec/dummy`
5. `bundle install`
6. `bundle exec rake db:migrate`
7. `rails s`

## Contributing
Contributions are most welcome, but remember: You're required to be nice to others! It's the law!

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
