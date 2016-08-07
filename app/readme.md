Order Logic

Once the order is scheduled, the cards are put on hold.

order status
-> new
(all statuses beyond here, cards are unavailable for)
-> scheduled
-> to be shipped
-> shipped
-> returning
(once the order is complete, cards are available)
-> complete

Once the user sets a schedule, availability is evaluated and order status is set to "scheduled".

The user next goes to the credit card auth form. If authroized, the status is set to "to be shipped".




Admin will log in and see a link to an order management page with a count of unshipped orders. There will be an index and show page for orders of each type ­ unshipped, shipped, returning, closed.

plug in routes and actions for shipping orders,
admin clicks order shipped,
cards are due back x number of days later plus shipping time
*** need to indicate on orders page when they want their cards and for how long.

*** when admin clicks order shipped, state is updated and email is sent to user

Make heroku scheduler task
-> send email re cards due back soon
-> send email re cards due, click when shipped
** create an anonomyzed token for each order once shipped
** prepare route for updating order and printing a thank you to the user.

-> add deck returned link



Number	Card type
4242424242424242	Visa
4012888888881881	Visa
4000056655665556	Visa (debit)
5555555555554444	MasterCard
5200828282828210	MasterCard (debit)
5105105105105100	MasterCard (prepaid)
378282246310005	American Express
371449635398431	American Express
6011111111111117	Discover
6011000990139424	Discover
30569309025904	Diners Club
38520000023237	Diners Club
3530111333300000	JCB
3566002020360505	JCB


Number	Description
+ This card will authorize, but will not be charged successfully.
4000000000000341	Attaching this card to a Customer object will succeed, but attempts to charge the customer will fail.

This card will not authorize
4000000000000002	Charges with this card will always be declined with a card_declined code.

4000000000000127	Charge will be declined with an incorrect_cvc code.
4000000000000069	Charge will be declined with an expired_card code.
4000000000000119	Charge will be declined with a processing_error code.
