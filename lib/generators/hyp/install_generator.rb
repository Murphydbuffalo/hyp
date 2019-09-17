# frozen_string_literal: true

module Hyp
  module Generators
    class InstallGenerator < Rails::Generators::Base
      class_option 'db-interface', type: :string, default: 'active_record'
      class_option 'user-class',   type: :string, default: 'User'
      source_root Hyp::Engine.root

      def create_initializer
        file_contents = <<-FILE
Hyp.db_interface = :#{options['db-interface']}
Hyp.user_class_name = '#{options['user-class']}'
        FILE

        create_file 'config/initializers/hyp.rb', file_contents
      end

      def mount_engine
        route "mount Hyp::Engine => '/hyp'"
      end

      def copy_migrations
        return unless options['db-interface'] == 'active_record'

        Dir[Hyp::Engine.root.join("db/migrate/*.rb")].each_with_index do |migration, i|
          name      = migration.split('/').last.split('_').slice(1..-1).join('_')
          timestamp = (Time.current.strftime('%Y%m%d%H%M%S').to_i + i).to_s

          if Rails.root.join("db/migrate/*#{name}").exist?
            puts "Migration #{name} has already been copied to your app"
          else
            copy_file migration, "db/migrate/#{timestamp}_#{name}"
          end
        end
      end
    end
  end
end
