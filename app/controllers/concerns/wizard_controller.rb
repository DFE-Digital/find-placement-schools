module WizardController
  extend ActiveSupport::Concern

  included do
    helper_method :current_step_path, :back_link_path, :step_path, :index_path
    after_action :persist_wizard_state

    def new
      redirect_to step_path(@wizard.first_step)
    end

    def edit; end

    private

    def wizard_state
      @wizard_state ||= session.fetch(state_key, {}).dup
    end

    def persist_wizard_state
      return unless instance_variable_defined?(:@wizard)
      return unless @wizard.respond_to?(:state)

      session[state_key] = @wizard.state.dup
    end

    def state_key
      @state_key ||= params.fetch(:state_key, BaseWizard.generate_state_key)
    end

    def current_step_path
      step_path(@wizard.current_step)
    end

    def back_link_path
      if @wizard.previous_step.present?
        step_path(@wizard.previous_step)
      else
        index_path
      end
    end

    def index_path
      raise "Index path not set"
    end
  end
end
