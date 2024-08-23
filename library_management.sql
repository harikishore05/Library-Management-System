-- Table to store information about books

create database library_management

use library_management

CREATE TABLE Books (
    BookID INT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    AuthorID INT,
    CategoryID INT,
    YearPublished INT,
    AvailableCopies INT,
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Table to store information about authors
CREATE TABLE Authors (
    AuthorID INT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL
);

-- Table to store book categories
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL
);

-- Table to store library members
CREATE TABLE Members (
    MemberID INT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE,
    MembershipDate DATE NOT NULL
);

-- Table to manage loans of books
CREATE TABLE Loans (
    LoanID INT PRIMARY KEY,
    BookID INT,
    MemberID INT,
    LoanDate DATE,
    DueDate DATE,
    ReturnDate DATE,
    FOREIGN KEY (BookID) REFERENCES Books(BookID),
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID)
);

-- Inserting data into Authors table
INSERT INTO Authors (AuthorID, Name)
VALUES 
(1, 'J.K. Rowling'),
(2, 'George Orwell'),
(3, 'J.R.R. Tolkien');

-- Inserting data into Categories table
INSERT INTO Categories (CategoryID, CategoryName)
VALUES 
(1, 'Fiction'),
(2, 'Science Fiction'),
(3, 'Fantasy');

-- Inserting data into Books table
INSERT INTO Books (BookID, Title, AuthorID, CategoryID, YearPublished, AvailableCopies)
VALUES 
(1, 'Harry Potter and the Philosopher''s Stone', 1, 3, 1997, 5),
(2, '1984', 2, 2, 1949, 3),
(3, 'The Lord of the Rings', 3, 3, 1954, 4);

-- Inserting data into Members table
INSERT INTO Members (MemberID, Name, Email, MembershipDate)
VALUES 
(1, 'Alice Smith', 'alice@example.com', '2023-01-15'),
(2, 'Bob Johnson', 'bob@example.com', '2023-02-20');

-- Inserting data into Loans table
INSERT INTO Loans (LoanID, BookID, MemberID, LoanDate, DueDate, ReturnDate)
VALUES 
(1, 1, 1, '2024-08-01', '2024-08-15', NULL),
(2, 2, 2, '2024-08-05', '2024-08-19', NULL);

SELECT Title, AvailableCopies 
FROM Books 
WHERE AvailableCopies > 0;

SELECT B.Title 
FROM Books B
JOIN Authors A ON B.AuthorID = A.AuthorID
WHERE A.Name = 'J.K. Rowling';

SELECT M.Name AS MemberName, B.Title, L.DueDate
FROM Loans L
JOIN Members M ON L.MemberID = M.MemberID
JOIN Books B ON L.BookID = B.BookID
WHERE L.DueDate < CURDATE() AND L.ReturnDate IS NULL;

UPDATE Loans
SET ReturnDate = CURDATE()
WHERE LoanID = 1;

UPDATE Books
SET AvailableCopies = AvailableCopies + 1
WHERE BookID = (SELECT BookID FROM Loans WHERE LoanID = 1);

INSERT INTO Loans (LoanID, BookID, MemberID, LoanDate, DueDate, ReturnDate)
VALUES (3, 3, 1, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), NULL);

UPDATE Books
SET AvailableCopies = AvailableCopies - 1
WHERE BookID = 3;

ALTER TABLE Loans
ADD CONSTRAINT chk_DueDate CHECK (DueDate > LoanDate);

CREATE INDEX idx_BookTitle ON Books(Title);
CREATE INDEX idx_MemberName ON Members(Name);

DELIMITER $$

CREATE TRIGGER UpdateAvailableCopiesAfterReturn
AFTER UPDATE ON Loans
FOR EACH ROW
BEGIN
    -- Check if the ReturnDate has been updated (i.e., it is not NULL)
    IF NEW.ReturnDate IS NOT NULL THEN
        -- Update the AvailableCopies in the Books table
        UPDATE Books
        SET AvailableCopies = AvailableCopies + 1
        WHERE BookID = NEW.BookID;
    END IF;
END $$

DELIMITER ;
