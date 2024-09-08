
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
 
 /*
 Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" 
when they are returned (based on entries in the return_status table).
*/

DELIMITER //

CREATE PROCEDURE add_return_records(
    IN p_return_id VARCHAR(10),
    IN p_issued_id VARCHAR(10)
)
BEGIN
    DECLARE v_isbn VARCHAR(50);
    DECLARE v_book_name VARCHAR(80);

    -- Insert a new record into retur_status
    INSERT INTO return_status (return_id, issued_id, return_date)
    VALUES (p_return_id, p_issued_id, CURDATE());

    -- Select issued book details into variables
    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    -- Update the status of the book
    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    -- Output a message (MySQL does not support RAISE NOTICE, so use SELECT instead)
    SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS message;
END //

DELIMITER ;

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';


-- calling function 
CALL add_return_records('RS138', 'IS135');

-- calling function 
CALL add_return_records('RS148', 'IS140');

/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, 
showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/
CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;

/* 
Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members
 who have issued at least one book in the last 6 months.
*/

create table active_members
as 
select * from members
where member_id in (
select distinct issued_member_id
from issued_status
where issued_date >= curdate() - interval 6 month);

select * from active_members;

/*
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues.
 Display the employee name, number of books processed, and their branch.
 */

select emp_name, b.*, count(issued_id) as no_of_books_ssued
from employees e inner join issued_status ist
on e.emp_id = ist.issued_emp_id
inner join branch b
on e.branch_id = b.branch_id
group by 1, 2
order by no_of_books_ssued desc
limit 3;

/* 
Task 18: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system.
 Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
 The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
 The procedure should first check if the book is available (status = 'yes'). 
 If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
 If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/

DELIMITER //

CREATE PROCEDURE issue_book(
    IN p_issued_id VARCHAR(10),
    IN p_issued_member_id VARCHAR(30),
    IN p_issued_book_isbn VARCHAR(30),
    IN p_issued_emp_id VARCHAR(10)
)
BEGIN
    DECLARE v_status VARCHAR(10);

    SELECT status
    INTO v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN
      
        INSERT INTO issued_status (issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES (p_issued_id, p_issued_member_id, CURDATE(), p_issued_book_isbn, p_issued_emp_id);

  
        UPDATE books
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

    
        SELECT CONCAT('Book records added successfully for book isbn: ', p_issued_book_isbn) AS message;

    ELSE

        SELECT CONCAT('Sorry to inform you, the book you have requested is unavailable. Book ISBN: ', p_issued_book_isbn) AS message;
    END IF;
END //

DELIMITER ;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');










