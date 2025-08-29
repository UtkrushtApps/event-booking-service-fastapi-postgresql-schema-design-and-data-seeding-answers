-- Drop tables if existing (for idempotent re-runs)
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS events CASCADE;

-- 1. USERS table
drop sequence if exists users_id_seq;
CREATE SEQUENCE users_id_seq START 1;

CREATE TABLE users (
    id        integer PRIMARY KEY DEFAULT nextval('users_id_seq'),
    name      VARCHAR(100) NOT NULL,
    email     VARCHAR(100) UNIQUE NOT NULL
);

-- 2. EVENTS table
drop sequence if exists events_id_seq;
CREATE SEQUENCE events_id_seq START 1;

CREATE TABLE events (
    id          integer PRIMARY KEY DEFAULT nextval('events_id_seq'),
    title       VARCHAR(200) NOT NULL,
    event_date  TIMESTAMP NOT NULL,
    capacity    INTEGER NOT NULL CHECK (capacity > 0)
);

-- 3. BOOKINGS table
drop sequence if exists bookings_id_seq;
CREATE SEQUENCE bookings_id_seq START 1;

CREATE TABLE bookings (
    id           integer PRIMARY KEY DEFAULT nextval('bookings_id_seq'),
    user_id      INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    event_id     INTEGER NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    seats_booked INTEGER NOT NULL CHECK (seats_booked > 0),
    booked_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_user_event UNIQUE (user_id, event_id, booked_at)  -- allow multi-bookings for an event, but not at same time by same user
);

-- Seed USERS (~10 users)
INSERT INTO users (name, email) VALUES
    ('Alice Wonderland', 'alice@example.com'),
    ('Bob Builder', 'bob@example.com'),
    ('Charlie Day', 'charlie@example.com'),
    ('Daisy Meadows', 'daisy@example.com'),
    ('Eliot Page', 'eliot@example.com'),
    ('Fatima Noor', 'fatima@example.com'),
    ('George Lucas', 'george@example.com'),
    ('Hannah Baker', 'hannah@example.com'),
    ('Ivan Petrov', 'ivan@example.com'),
    ('Jenna Smith', 'jenna@example.com');

-- Seed EVENTS (~6, mix past/future/capacity)
INSERT INTO events (title, event_date, capacity) VALUES
    ('Jazz Festival',         '2023-10-10 19:00:00+00', 150),  -- past
    ('Tech Summit 2024',      '2024-08-15 09:00:00+00', 500),  -- future
    ('Cooking Workshop',      '2024-05-10 16:00:00+00', 25),   -- past
    ('Startup Pitch Night',   '2024-06-22 18:30:00+00', 40),   -- future
    ('Kids Art Camp',         '2024-07-01 09:00:00+00', 20),   -- future
    ('Rock Concert',          '2024-04-01 20:00:00+00', 300);  -- past

-- Seed BOOKINGS (~18 rows, multi-seat, full/partial/none)
-- Book some capacity-ful events, others with space, multi-seat bookings included.
INSERT INTO bookings (user_id, event_id, seats_booked, booked_at) VALUES
    -- Jazz Festival (id=1, capacity=150)
    (1, 1, 2, '2023-09-01 10:00:00+00'),   -- Alice
    (2, 1, 4, '2023-09-02 13:00:00+00'),   -- Bob
    (3, 1, 10,'2023-09-10 15:20:00+00'),   -- Charlie
    (4, 1, 50,'2023-09-15 11:00:00+00'),   -- Daisy
    (5, 1, 84,'2023-09-17 12:00:00+00'),   -- Eliot (event total = 2+4+10+50+84 = 150, fully booked)

    -- Tech Summit 2024 (id=2, capacity=500)
    (6, 2, 1, '2024-03-01 09:00:00+00'),   -- Fatima
    (7, 2, 3, '2024-04-10 14:00:00+00'),   -- George
    (8, 2, 5, '2024-04-25 19:00:00+00'),   -- Hannah
    (9, 2, 10,'2024-05-20 20:00:00+00'),   -- Ivan

    -- Cooking Workshop (id=3, capacity=25, almost full)
    (10,3, 5, '2024-04-20 17:00:00+00'),   -- Jenna
    (1, 3, 6, '2024-04-21 09:30:00+00'),   -- Alice
    (2, 3, 4, '2024-04-23 10:00:00+00'),   -- Bob
    (3, 3, 7, '2024-04-25 12:00:00+00'),   -- Charlie
    (4, 3, 3, '2024-04-28 08:00:00+00'),   -- Daisy (5+6+4+7+3=25, fully booked)

    -- Startup Pitch Night (id=4, capacity=40, some remaining)
    (5, 4, 10,'2024-06-01 16:00:00+00'),   -- Eliot
    (6, 4, 20,'2024-06-04 13:00:00+00'),   -- Fatima
    (7, 4, 8, '2024-06-10 14:30:00+00');   -- George
    -- so 38/40 booked, 2 seats available
-- Kids Art Camp and Rock Concert: no bookings yet, all seats available (testing empty bookings & all seats open)

-- The data above ensures:
-- - Fully booked events (Jazz Festival, Cooking Workshop)
-- - Some events with partial bookings (Tech Summit, Startup Pitch, Kids Art Camp, Rock Concert)
-- - Some multi-seat bookings by users
-- - Some users booked multiple events
-- - Some events with no bookings
-- - Bookings spanning past & future.
