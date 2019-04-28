require "hyp/engine"

module Hyp
  # Can do something like this to make the database configurable...
  mattr_accessor :database
  database = :active_record
end
