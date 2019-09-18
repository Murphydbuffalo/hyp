idiots = Idiot.create!([
  {name: 'Dan', age: 1},
  {name: 'Mark', age: 2},
  {name: 'Allan', age: 0},
  {name: 'Anna', age: 99},
  {name: 'Jon', age: 55},
  {name: 'Aaron', age: 12},
  {name: 'Raph', age: 1},
  {name: 'Elisse', age: 2},
  {name: 'Maja', age: 0},
  {name: 'Ben', age: 99},
  {name: 'Kate', age: 55},
  {name: 'Connie', age: 12},
  {name: 'Lauren', age: 1},
  {name: 'Emily', age: 2},
  {name: 'Maddy', age: 0},
  {name: 'Chris', age: 99},
  {name: 'Betty', age: 55},
  {name: 'Tre', age: 12},
  {name: 'Danielle', age: 2},
  {name: 'Brian', age: 0},
  {name: 'Josh', age: 99},
  {name: 'Amber', age: 55},
  {name: 'Armando', age: 55}
])

exp = Hyp::ExperimentRepo.create(
  name: 'Sign Up CTA Copy',
  control: 0.01,
  minimum_detectable_effect: 0.2
)

idiots.each do |idiot|
  exp.record_conversion(idiot)
end
