require "hyp/engine"

module Hyp
  mattr_accessor :database
  database = :active_record
end
