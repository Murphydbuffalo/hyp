# frozen_string_literal: true

require "hyp/engine"

module Hyp
  mattr_writer :db_interface, :user_class_name
  mattr_accessor :experiment_complete_callback

  def self.db_interface
    if @@db_interface.in?(%i[active_record mongoid])
      @@db_interface
    elsif @@db_interface.nil?
      :active_record
    else
      raise 'db_interface must be either :active_record or :mongoid'
    end
  end

  def self.user_class_name
    @@user_class_name.nil? ? 'User' : @@user_class_name
  end

  def self.user_class
    user_class_name.constantize
  end

  def self.user_foreign_key_name
    "#{user_class_name.downcase}_id".to_sym
  end

  def self.user_relation_name
    user_class_name.downcase.pluralize.to_sym
  end
end
