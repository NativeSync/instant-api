module Request
  class Update < AuthenticatedRequestBase
    attr_accessor :error, :results
    def initialize(api)
      super(api)
      @results = []
      api.params[api.object_name.pluralize].each do |object|
        object = preprocess_object(object)
        begin
          object_id = object[api.object_schema['primary_key']]
          result = api.db.from(api.object_schema['table_name'])
                      .where(api.object_schema['primary_key'].to_sym => object_id)
                      .update(object)
        rescue Sequel::Error
          log_error($!.message)
        end

        if (result)
          @results << {id: object_id, success: true}
        else
          @results << {success: false, error: 'failed to update'}
        end
      end

    end

  end
end
