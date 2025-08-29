# Solution Steps

1. Design the normalized schema with three tables: users, events, and bookings. Each must have an integer primary key. Bookings must reference both users and events (with cascading deletes), track seat counts, and have timestamps.

2. Write DDL to create the users table (id, name, email), ensuring email is unique.

3. Write DDL for the events table (id, title, event_date, capacity). Add a constraint so capacity is always positive.

4. Write DDL for the bookings table (id, user_id, event_id, seats_booked, booked_at). Add foreign keys for user_id and event_id, a constraint that seats_booked is positive, and a unique index on (user_id, event_id, booked_at) to allow multiple bookings per event.

5. Create SQL sequences for PK autoincrement (PostgreSQL compatible).

6. Seed ~10 diverse users into the users table.

7. Seed ~6 events, ensuring a mix of past and future event_date values and a range of capacities (from small to large).

8. Seed ~18 booking rows: populate bookings for some events to full capacity (with multi-seat bookings), partially fill some, and leave at least two events with zero bookings.

9. Ensure the seeded data covers edge cases: fully-booked events, partially booked, and totally unbooked events; multi-bookings from the same user; and bookings that span past and future dates.

10. Write a Python script (using psycopg2) to execute the schema SQL file against the PostgreSQL database, running both schema definition and seed data in one shot. Make DB connection parameters configurable via environment variables.

11. Test: After running the script, check in PostgreSQL that tables and data are created and constraints are enforced (e.g. fully booked event's sum(seats_booked) == capacity, unique email, foreign keys, etc.).

