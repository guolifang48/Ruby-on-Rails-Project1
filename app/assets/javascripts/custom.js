$(document).ready(function(){
  $("a.card-image-link").tooltip(
    {'placement': 'right','content':'html'}
  );
});

$(document).ready(function(){

  $("#card-search").autocomplete(
    {
      dataType: "json",
      source: $('#card-search').data('autocomplete-source'),
      minLength: 2,
      _renderItem: function( ul, item ) {
        return $( "<li>" )
        .attr( "data-value", item.value )
        .append("<img src='" + item.card_image_url + "' />")
        .appendTo( ul );
      },
      focus: function (event, ui) {
        this.value = ui.item.label;
        event.preventDefault();
      },
      select: function( event, ui ) {
        this.value = ui.item.label;
        event.preventDefault();
      }
    }
  );

  $.ui.autocomplete.prototype._renderItem = function(ul, item) {
    return $("<li></li>")
    .data("item.autocomplete", item)
    .append(
      '<a href="' + item.search_cards_url + '"><div class="ui-card-price pull-right badge badge-success">' + item.card_price + '</div>'
      +  '<img src="' + item.card_image_url + '" class="pull-left ui-card-image" />'
      +  '<div class="ui-card-title">' + item.label + '</div>'
      +  '<div class="ui-card-type">' + item.card_color_and_type + ' | ' + item.card_rarity + '</div>'
      +  '<div class="ui-card-description">' + item.card_text + '</div>'
      + '<div class="clear"></div></a>'
    )
    .appendTo( ul );
  };
});


// Parallax code

$(document).ready(function(){
   var $bgobj = $('#callout-row'); // assigning the object

   $(window).scroll(function() {
       var yPos = -($(window).scrollTop() / $bgobj.data('speed'));

       // Put together our final background position
       var coords = '50% '+ yPos + 'px';
       // Move the background
       $bgobj.css({ backgroundPosition: coords });
   });
});


// Payment/ Shipping form code

$(document).ready(function(){

  var state_select_val = $('select#order_province').val();

  $('select#order_province').on("change", function(){
    var state_select_val = $(this).val();
    if (state_select_val == 'IN'){
      $('.tax-notification').removeClass('hide');
    }
    else {
      $('.tax-notification').addClass('hide');
    }
  });

});


function updateCartSubtotals() {
  var cards_price = $('ul#cart-table').attr('data-cards-subtotal');
  var shipping_price = $('ul#subtotal-rows').attr('data-cart-shipping');
  var rental_price = $('ul#subtotal-rows').attr('data-cart-rental');

  var sum_price = parseInt(cards_price) + parseInt(rental_price);
  $('span#cart-cards-subtotal').text((sum_price/100).toFixed(2));

  var cart_subtotal = parseInt(cards_price) + parseInt(rental_price) + parseInt(shipping_price);
  $('span#cart-cart-subtotal').text((cart_subtotal/100).toFixed(2));
}
