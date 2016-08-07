jQuery ->
  Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))
  cart_auth.setupForm()

cart_auth =
  setupForm: ->
    $('form:has(#card_number)').submit ->
      $('#address_error').addClass('hide')
      $('input').removeClass('has-error');
      $('select').removeClass('has-error');
      if !$('#stripe_error').hasClass('hide')
        $('#stripe_error').addClass('hide')
      $('input[type=submit]').attr('disabled', true)
      if $('#card_number').length
        if cart_auth.verifyAddress()
          $('#address_error').addClass('hide')
          $('input').removeClass('has-error');
          $('select').removeClass('has-error');
          cart_auth.processCard()
        else
          $('#address_error').removeClass('hide').text('Please provide your complete shipping address')
          $('input[type=submit]').attr('disabled', false)
        false
      else
        true

  verifyAddress: ->
    valid = true
    if $('#order_ship_to_name').val() == ''
      valid = false
      $('#order_ship_to_name').addClass('has-error');
    if $('#order_street_address_first_line').val() == ''
      valid = false
      $('#order_street_address_first_line').addClass('has-error');
    if $('#order_city').val() == ''
      valid = false
      $('#order_city').addClass('has-error');
    if $('#order_province').val() == ''
      valid = false
      $('#order_province').addClass('has-error');
    if $('#order_zipcode').val() == ''
      valid = false
      $('#order_zipcode').addClass('has-error');
    if valid
      return true
    else
      return false

  processCard: ->
    card =
      number: $('#card_number').val()
      cvc: $('#card_code').val()
      expMonth: $('#card_month').val()
      expYear: $('#card_year').val()
    Stripe.createToken(card, cart_auth.handleStripeResponse)

  handleStripeResponse: (status, response) ->
    if status == 200
      if response['card']['funding'] == 'prepaid'
        $('#error_explanation').remove();
        $('#stripe_error').removeClass('hide').text( "We're sorry but we don't accept prepaid cards at this time. Please enter a valid credit card." )
        $('input[type=submit]').attr('disabled', false)
      else
        $('#stripe_card_token').val(response.id)
        $('form:has(#card_number)')[0].submit()
    else
      $('#error_explanation').remove();
      $('#stripe_error').removeClass('hide').text( response.error.message )
      $('input[type=submit]').attr('disabled', false)
