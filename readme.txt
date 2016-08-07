Order Flow

===================
= the order model =
===================

The order model has a number of attributes associated with its ecommerce life cycle.

============
= the cart =
============

When a user first comes to the site a new order objected is initialized and saved. This order serves as the user's "cart". If the user already has an order object that has not been authorized, then that order will be loaded as the cart.

Order cards

The user will then shop around the site adding cards to the the cart via an order_cards join model. +special cases: template_decks. There are three ways of doing this, searching for a card, adding via the quick add form on the cart page, browsing for cards or adding a template deck.

Checkout and Authorization

Once a user has assembled their desired deck the will select how and when they want it shipped and proceed to the payment page. On the payment page their will provide their credit card info which will be authorized against the total amount of the order.

  order.authorized = Time.zone.now
  order.pending = true or false

  At this stage the availability logic is run. For each card in the cart, the site will check if it's available at the requested quantity for each of the days of the order. **this is done using available_for

  A deck_available method will be called from the order model.

  If the deck is not available, the user will be presented with a next available date and asked if they want to continue with their order.

  If they continue, the order will be marked pending, with the unavailable cards marked, "needed". Needed cards will be displayed on a separate admin page.

  "Open" orders are orders that are both available and authorized.

  Three times a day, a cron is run that will check if pending orders can now be switched to Open.



************

Guest record logic

-> if user isn't logged in create a guest record.
App controller method for this, then

if not_logged_in, guest record
  cart
else
  cart present?
    cart
  else
    new cart


If a user who had been adding cards to a cart logs in, the older cart should be destroyed, and the existing one imported.


The presence of unavailable cards blocks progress through order system. order_card availablility is determined by the card and timing attributes of the order.


