module Request
  class GetRecent < AuthenticatedRequestBase
    attr_accessor :error, :results
    def initialize(api)
      super(api)
      @error = 400 if api.params[:from_date].blank?
      @error = 400 if api.params[:to_date].blank?

      if (api.params[:page].blank?)
        api.params[:page] = 0
      end

      begin
        limit = 100
        @results = api.db.from(api.object_schema['table_name'])
        .limit(limit)
        .offset(api.params[:page].to_i * limit)
        .where(api.object_schema['update_timestamp'].to_sym => api.params[:from_date]..api.params[:to_date])
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
