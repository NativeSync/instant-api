def get_actor(last_name = 'bryant', actor_id = nil)
  val = {last_name: last_name}
  val['actor_id'] = actor_id unless actor_id.blank?
  val
end

def get_success(id)
  {success: true, id: id}
end
