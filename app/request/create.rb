module Request
  class Create < AuthenticatedRequestBase
    attr_accessor :error, :results
    def initialize(api)
      super(api)

      @results = []
      api.params[@api.object_name.pluralize].each do |object|
        object = preprocess_object(object)
        begin
          result = api.db.from(api.object_schema['table_name']).insert(object)
        rescue Sequel::Error
          log_error($!.message)
          # TODO: Log in ELK
        end

        if (result)
          @results << {id: result.to_s, success: true}
        else
          @results << {success: false, error: 'failed to insert'}
        end
      end
    end
  end
end
