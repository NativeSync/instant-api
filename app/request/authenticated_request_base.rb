module Request
  class AuthenticatedRequestBase
    def initialize(api)
      @api = api
    end

    # preprocess an object for insert/update in the DB
    def preprocess_object(object)
      if (@api.api_config['partition_strategy'] == 'client_id')
        object[@api.object_schema['client_id']] = @api.client_info['client_id']
      end
      object[@api.object_schema['update_timestamp']] = Time.now unless @api.api_config['auto_update_ts'] == true
      object
    end

    def log_error(error)
      p "TODO: log errors in ELK"
      p error
    end
  end
end
