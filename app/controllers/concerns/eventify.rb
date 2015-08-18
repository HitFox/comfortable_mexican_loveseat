module Eventify
  extend ActiveSupport::Concern
  
  included do
    resource_class.state_machine.events.map(&:name).each do |event|
      define_method event do
        respond_to do |format|
          format.html do
            resource.assign_attributes(permitted_params[resource_instance_name]) if permitted_params[resource_instance_name]
            
            if resource.fire_state_event(event)
              redirect_to [current_namespace, current_parent, resource], notice: t('flash.success', action_name: resource_class.human_state_event_name(event).capitalize)
            else
              flash[:alert] = resource.errors.full_messages.join('<br>')
              render action: :show
            end
          end
        end
      end
    end
  end
end
