module Request
  class Get < AuthenticatedRequestBase
    attr_accessor :error, :results
    def initialize(api)
      super(api)
      @error = 400 if api.params[:page].blank?
      begin
        limit = 100
        @results = api.db.from(api.object_schema['table_name'])
                     .limit(limit)
                     .offset(api.params[:page].to_i * limit)
        if (api.api_config['partition_strategy'] == 'client_id')
          @results = @results.where(api.object_schema['client_id'].to_sym => api.client_info['client_id'])
        end
      rescue Sequel::Error
        log_error($!.message)
        # TODO: Log in ELK
      end
    end
  end
end
