module Request
  class ApiSpec < AuthenticatedRequestBase
    attr_accessor :error, :results

    def initialize(api)
      super(api)
      api_spec = {
        'api_type' => 'nativeapi',
        'credentials_template' => {
          'X_API_KEY' => 'Api Key',
          'X_SECRET_KEY' => 'Secret Key'
        },
        'auth_type' => 'headers',
        'date_format' => api.api_config['date_format'],
        'base_url' = api.api_config['base_url'],
        'database_type' => api.db.database_type,
        'sync_objects' => {},
      }

      api.api_config['sync_objects'].each do |object_name, object|
        unique_keys = []
        required_fields = []
        fields = { }
        api.db.schema(object['table_name']). each do |field|
          field_name = field.first.to_s
          if (field.last[:allow_null] == false && field.last[:default].blank?)
            required_fields << field_name
          end

          field_type = field.last[:type]
          fields[field_name] = {'label' => field_name.camelize, 'data_type' => field_type}
        end

        api.db.indexes(object['table_name']).each do |index_name, index|
          next unless index[:unique] == true
          columns = []
          index[:columns].each do |column|
            columns << column.to_s
          end
          unique_keys << columns
        end
        api_spec['sync_objects'][object_name] = {
          'update_timestamp' => object['update_timestamp'],
          'primary_key' => object['primary_key'],
          'unique_keys' => unique_keys,
          'required_fields' => required_fields,
          'fields' => fields
        }
      end

      @results = api_spec
    end

  end
end
