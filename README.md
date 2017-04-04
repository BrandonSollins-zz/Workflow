# Booking Workflow

1. Booking is filled out on custom-tracks.com and an email is sent to >insert email here<.
2. Zapier notifies the app that an email has been received by sending a POST request to /workflow/email.
3. The email is parsed and the following are extracted:
  4. Required instruments
  5. Available times between the studio and client
  6. Available musicians during those times
  7. Possible times to send out texts where a group of musicians are available (if None, notify Dane)
8. A new Booking object is created.
9. The first group of text messages are sent out. Messages are sent out in order according to the following rules:
  10. Available times between 10-6 EST, and sort from earliest to latest + add to list.
  11. Available times outside of 10-6 EST, and sort from earliest to latest + add to list.
  12. For each time with multiple musicians, determine how many days since last booking. Sort musicians from smallest to largest.
13. Each text message contains links to a yes and no route with the required information to continue the booking workflow. If the musician selects no, this response is recorded with no further action. If the musician selects yes, the response is recorded, and the following logic is applied:
  14. Has the instrument already been accounted for?
    15. If yes, do nothing.
    16. If no, add that instrument and musician to the booking.
  17. If added, are all required instruments now accounted for?
    18. If no, do nothing.
    19. If yes, add calendar event to each musicians calendar, and send a confirmation text message to each musician + Dane.
13. Every >XXX minutes (possibly 15?)< check the status of the new booking. This checks for any booking not completed, whose last message was >= 1 hour ago. If more messages are able to sent, the next message is sent (should we void the previous messages?). If bookings are not complete and no more messages are able to sent, Dane is contacted.




# Work To Do
1. MOVE TO AWS/UPDATE CODE TO CURRENT R&R
2. GET STUDIO'S SCHEDULE
3. TIMEZONES!?!?!
2. Write code to send messages using Nexmo (or similar service)
3. Build messages table with the following fields:
  4. musician_id
  5. option
  6. booking_id
  7. booking_time
  8. instrument
9. Figure out running background worker. 95% sure I know what to do here, just need to be using AWS
10. Build background worker controller
11. Build YES/NO response controllers
12. Build YES/NO response views

# Wishlist

1. Bookings dashboard to view all info for a given booking in real time

# Blue Sky Ideas
