$('.invite-error').remove();
$('.signin-register-row').before('<div class="invite-error text-danger text-bold"><%= @errors %></div>');
