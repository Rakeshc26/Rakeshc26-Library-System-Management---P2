-- project task
-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

insert into books(isbn, book_title, category, rental_price, status, author, publisher)
values('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Task 2: Update an Existing Member's Address

UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

delete from issued_status
where issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

select * from issued_status
where issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

select issued_emp_id , count(issued_id) as total_books_issued from issued_status
group by 1
having count(*) > 1;

-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

create table book_cnts
as
select b.isbn,
b.book_title,
count(ist.issued_id) as no_issued
from books b inner join issued_status ist
on ist.issued_book_isbn = b.isbn
group by 1, 2;

select * from book_cnts;

-- Task 7. Retrieve All Books in a Specific Category:

select * from books
where category = 'classic';

-- Task 8: Find Total Rental Income by Category:
select b.category, sum(rental_price) as rental_income
from books b inner join issued_status ist
on b.isbn = ist.issued_book_isbn
group by 1;


-- Task9: List Members Who Registered in the Last 180 Days:
SELECT * 
FROM members
WHERE reg_date > CURDATE() - INTERVAL 180 DAY;

-- Task10: List Employees with Their Branch Manager's Name and their branch details:

select e1.*, b.manager_id, e2.emp_name as manager_name
from employees e1 inner join branch b
on e1.branch_id = b.branch_id
inner join employees e2 
on b.manager_id = e2.emp_id; 

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold like $7:

CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;

select * from expensive_books;

-- Task 12: Retrieve the List of Books Not Yet Returned

select * from issued_status
where issued_id not in(select issued_id from return_status);

/* 
Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period).
 Display the member's_id, member's name, book title, issue date, and days overdue.
 */
 
 select ist.issued_member_id,
 m.member_name,
 b.book_title,
 issued_date,
 datediff(curdate(), issued_date) as over_due_days
 from issued_status ist inner join members m 
 on m.member_id = ist.issued_member_id
 inner join books b 
 on ist.issued_book_isbn = b.isbn
 left join return_status r
 on r.issued_id = ist.issued_id
 where return_id is null
 and (curdate() - issued_date) > 30
 order by 1;
 

 

