module Plz
  module Commands
    class SchemaFileNotFound
      def call
        puts "Schema file was not found in #{CommandBuilder::SCHEMA_FILE_PATH_PATTERN}"
      end
    end
  end
end
