module AdminHelper

  def admin_controller?
    controller.class.name.split("::").first=="Admin"
  end

end
