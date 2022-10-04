if not exists(select * from sys.databases where name='nestdb')
    CREATE DATABASE nestdb
GO

USE nestdb
GO

-- DOWN
--- Drop books fk
if exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME = 'fk_books_format_id')
    alter table books drop constraint fk_books_format_id
if exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME = 'fk_books_publisher_id')
    alter table books drop constraint fk_books_publisher_id
if exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME = 'fk_books_genre_id')
    alter table books drop constraint fk_books_genre_id
-- Drop loans fk
if exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME = 'fk_loans_member_id')
    alter table loans drop constraint fk_loans_member_id
if exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME = 'fk_loans_book_id')
    alter table loans drop constraint fk_loans_book_id
-- Drop request fk
if exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME = 'fk_requests_member_id')
    alter table requests drop constraint fk_requests_member_id
-- Drop tables
drop table if exists format_lookup
drop table if exists genre_lookup
drop table if exists publishers
drop table if exists members
drop table if exists books
drop table if exists loans
drop table if exists requests


-- UP METADATA
CREATE TABLE format_lookup ( -- Using look up table help with standardize value
    format_id int IDENTITY not null,
    description VARCHAR(255) not null,
    CONSTRAINT pk_format_lookup_format_id PRIMARY KEY (format_id)
)

CREATE TABLE genre_lookup (
    genre_id int IDENTITY not null,
    description VARCHAR(255) not null,
    CONSTRAINT pk_genre_lookup_genre_id PRIMARY KEY (genre_id)
)

CREATE TABLE publishers (
    publisher_id int IDENTITY not null,
    name VARCHAR(255) not null,
    website VARCHAR(255) not null,
    phone CHAR(10) unique not null, -- Using Char because using int will get rid of leading 0,
    CONSTRAINT pk_publishers_publisher_id PRIMARY KEY (publisher_id)
)

CREATE TABLE members (
    member_id int IDENTITY not null,
    first_name VARCHAR(50) not null,
    last_name VARCHAR(50) not null,
    email VARCHAR(255) unique not null,
    phone CHAR(10) unique not null,
    overdue_balance SMALLMONEY DEFAULT 0.0,
    CONSTRAINT members_member_id PRIMARY KEY (member_id)
)

CREATE TABLE books (
    book_id int IDENTITY not null,
    isbn CHAR(13) not null, -- ISBN ranged from 10 to 13 digit. Books before 2007 has 10 digits and vice versa.
    title VARCHAR(255) not null,
    author VARCHAR(255) not null,
    format_id int not null,
    publisher_id int not null,
    published_date Date not null,
    genre_id int not null,
    rating DECIMAL(2,1), -- allowed rating from 0.0 to 5.0
    CONSTRAINT books_book_id PRIMARY KEY (book_id)
)
ALTER TABLE books
    ADD CONSTRAINT fk_books_format_id FOREIGN KEY (format_id)
        REFERENCES format_lookup(format_id)
ALTER TABLE books
    ADD CONSTRAINT fk_books_publisher_id FOREIGN KEY (publisher_id)
        REFERENCES publishers(publisher_id)
ALTER TABLE books
    ADD CONSTRAINT fk_books_genre_id FOREIGN KEY (genre_id)
        REFERENCES genre_lookup(genre_id)

CREATE TABLE loans (
    loan_id int IDENTITY not null,
    member_id int not null,
    book_id int not null,
    check_out_date Date not null,
    due_date Date not null,
    return_date Date,
    CONSTRAINT loans_loan_id PRIMARY KEY (loan_id)
)
ALTER TABLE loans
    ADD CONSTRAINT fk_loans_member_id FOREIGN KEY (member_id)
        REFERENCES members(member_id)
ALTER TABLE loans
    ADD CONSTRAINT fk_loans_book_id FOREIGN KEY (book_id)
        REFERENCES books(book_id)

CREATE TABLE requests (
    request_id int IDENTITY not null,
    member_id int not null,
    isbn CHAR(13) not null,
    action CHAR(1) not null,
    description VARCHAR(255),
    CONSTRAINT requests_request_id PRIMARY KEY (request_id)
)
ALTER TABLE requests
    ADD CONSTRAINT fk_requests_member_id FOREIGN KEY (member_id)
        REFERENCES members(member_id)

-- UP DATA
--- Insert format
INSERT INTO format_lookup (description) VALUES
    ('Hard Cover'), ('Paperback'), ('E-book'), ('Audio Book')
--- Insert genre
INSERT INTO genre_lookup (description) VALUES
    ('Non-fiction'),('Bibliography'),('Fantasy'),
    ('SciFi'),('Action'),('Comedy'),
    ('Drama'),('Horror'),('Mystery'),
    ('Romance'),('Thriller'),('Religion'),
    ('History'),('Math'),('Statistic'), ('Management'),
    ('Economic'),('Progamming'),('Chemistry'),
    ('Physic'),('Biology'),('Psychology'), ('Philosophy'),
    ('Cooking'), ('Magazine'), ('Newspaper')
--- Insert publishers
INSERT INTO publishers (name, website, phone) VALUES
    ('publisher1', 'website1.com', '8005551001'),
    ('publisher2', 'website2.com', '8005551002'),
    ('publisher3', 'website3.com', '8005551003'),
    ('publisher4', 'website4.com', '8005551004'),
    ('publisher5', 'website5.com', '8005551005')
--- Insert members
INSERT INTO members (first_name, last_name, email, phone) VALUES
    ('firstname1', 'lastname1', 'email_1@gmail.com', '2025551001'),
    ('firstname2', 'lastname2', 'email_2@gmail.com', '2025551002'),
    ('firstname3', 'lastname3', 'email_3@gmail.com', '2025551003'),
    ('firstname4', 'lastname4', 'email_4@gmail.com', '2025551004'),
    ('firstname5', 'lastname5', 'email_5@gmail.com', '2025551005')
--- Insert books
INSERT INTO books (isbn, title, author, format_id, publisher_id, published_date, genre_id) VALUES
    ('1111111111111', 'Book1', 'Author1', 1, 1, '2011-4-15', 3),
    ('1111111111111', 'Book1', 'Author1', 2, 1, '2011-4-15', 3),
    ('1111111111111', 'Book1', 'Author1', 3, 2, '2015-4-15', 3),
    ('1111111111111', 'Book1', 'Author1', 4, 2, '2019-4-15', 3),
    ('2222222222222', 'Book2', 'Author2', 1, 1, '2009-4-15', 1),
    ('2222222222222', 'Book2', 'Author2', 1, 1, '2009-4-15', 1),
    ('2222222222222', 'Book2', 'Author2', 1, 2, '2012-4-15', 1),
    ('3333333333333', 'Book3', 'Author1', 3, 1, '2017-4-15', 9),
    ('4444444444444', 'Book4', 'Author3', 2, 4, '2019-4-15', 17),
    ('5555555555555', 'Book5', 'Author4', 3, 1, '2004-4-15', 18),
    ('4444444444444', 'Book4', 'Author3', 4, 3, '2015-4-15', 8),
    ('8888888888888', 'Book8', 'Author8', 1, 2, '2015-4-15', 11),
    ('9999999999999', 'Book9', 'Author9', 1, 1, '2013-4-15', 20),
    ('1212121212121', 'Book12', 'Author12', 2, 2, '2012-4-15', 12),
    ('7777777777777', 'Book7', 'Author1', 1, 1, '2010-4-15', 22),
    ('0909090909090', 'Book999', 'Author999', 2, 3, '2077-4-15', 5)
--- Insert loans
INSERT INTO loans (member_id, book_id, check_out_date, due_date) VALUES
    (1, 1, '2022-9-20', '2022-10-20'),
    (1, 2, '2022-9-20', '2022-10-20'),
    (1, 3, '2022-9-20', '2022-10-20'),
    (1, 4, '2022-9-20', '2022-10-20'),
    (2, 5, '2022-9-20', '2022-10-20'),
    (3, 6, '2022-9-26', '2022-10-26'),
    (4, 7, '2022-9-20', '2022-10-20'),
    (4, 8, '2022-9-20', '2022-10-20'),
    (5, 9, '2022-9-20', '2022-10-20'),
    (2, 10, '2022-9-20', '2022-10-20'),
    (4, 11, '2022-9-20', '2022-10-20')
--- Insert loans with return
INSERT INTO loans (member_id, book_id, check_out_date, due_date, return_date) VALUES
    (1, 1, '2022-9-15', '2022-10-15', '2022-9-20'),
    (3, 6, '2022-9-20', '2022-10-20', '2022-9-25')

--- Insert requests
INSERT INTO requests (member_id, isbn, action) VALUES
    (1, 1234567891111, 'A'),
    (3, 1111111111111, 'R'),
    (2, 1234567891111, 'A'),
    (4, 1234567891111, 'A'),
    (1, 1234567891111, 'A'),
    (3, 1111111111111, 'R'),
    (5, 5045080808480, 'R')


-- VERIFY
select * from format_lookup 
select TOP 5 * from genre_lookup
select * from publishers
select * from members
select TOP 5 * from books
select TOP 5 * from loans
select TOP 5* from requests

-- Advance SQL
--- IN STOCK
SELECT tb.isbn, total_books,
    total_books - ISNULL(total_loan, 0) + ISNULL(total_return, 0)  in_stock
FROM (
    SELECT isbn, count(*) as total_books
    FROM books b
    GROUP BY isbn ) tb
LEFT JOIN 
    (
    SELECT isbn, count(*) total_loan
    FROM loans l
    JOIN books b on l.book_id = b.book_id
    GROUP BY isbn ) tl on tb.isbn = tl.isbn
LEFT JOIN
    (
    SELECT isbn, count(*) total_return
    FROM loans l
    JOIN books b on l.book_id = b.book_id
    WHERE return_date IS NOT NULL
    GROUP BY isbn) tr on tb.isbn = tr.isbn


