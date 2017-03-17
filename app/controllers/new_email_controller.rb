class NewEmailController < ApplicationController

  def new
    @data = params[:data]
    @email = Email.new(
      :data => @data
    )
    @email.save!
    @email.trigger_workflow
  end

end
