create database libraries;
use libraries;
create table publisher (
          publisher_PublisherName      varchar(255),
          publisher_PublisherAddress   varchar(255),
          publisher_PublisherPhone     varchar(255), 
          primary key (publisher_PublisherName)
 );
 select * from publisher;
 
 
 create table borrower (
         borrower_CardNo           int,
         borrower_BorrowerName      varchar(255),
         borrower_BorrowerAddress   varchar(255),
         borrower_BorrowerPhone     varchar(255),
         primary key (borrower_CardNo)
);
select * from borrower;


create table library_branch (
		library_branch_BranchID            int  auto_increment,
        library_branch_BranchName         varchar(255),
        library_branch_BranchAddress      varchar(255),
        primary key (library_branch_BranchID)
);
select * from library_branch;


create table books (
       book_BookID            int,    
       book_Title             varchar(255),
       book_PublisherName     varchar(255),
       foreign key (book_PublisherName)   references publisher(publisher_PublisherName)  on delete cascade on update cascade,
       primary key(book_BookID)
);
select * from books;
       
create table book_loans (
       book_loans_LoansID      int auto_increment,
       book_loans_BookID       int,
       book_loans_BranchID     int,
       book_loans_CardNo       int,
       book_loans_DateOut      date,
       book_loans_DueDate      date,

       foreign key(book_loans_BookID)       references books(book_BookID)                        on delete cascade on update cascade,
       foreign key(book_loans_BranchID)     references library_branch(library_branch_BranchID)   on delete cascade on update cascade,
       foreign key(book_loans_CardNo)       references borrower(borrower_CardNo)                 on delete cascade on update cascade,
       primary key(book_loans_LoansID)
);
select * from book_loans;


create table book_copies (
      book_copies_CopiesID        int auto_increment,
      book_copies_BookID          int,
      book_copies_BranchID        int,
      book_copies_No_Of_Copies    int,
      foreign key(book_copies_BookID)               references books(book_BookID)                           on delete cascade on update cascade,
      foreign key(book_copies_BranchID)             references library_branch(library_branch_BranchID)      on delete cascade on update cascade,
      primary key(book_copies_CopiesID)
);
select * from book_copies;


create table authors (
      book_authors_AuthorsID               int  auto_increment,
      book_authors_BookID                  int,
      book_authors_AuthorName              varchar(255),
      foreign key(book_authors_BookID)                       references books(book_BookID)         on delete cascade on update cascade,
      primary key(book_authors_AuthorsID)
);
select * from authors;
--1--

SELECT COUNT(*)
FROM books b
JOIN book_copies bc ON b.book_BookID = bc.book_copies_BookID
JOIN library_branch lb ON bc.book_copies_BranchID = lb.library_branch_BranchID
WHERE b.book_Title = 'The Lost Tribe' AND lb.library_branch_BranchName = 'Sharpstown';


--2--

SELECT lb.library_branch_BranchName, COUNT(*)
FROM books b
JOIN book_copies bc ON b.book_BookID = bc.book_copies_BookID
JOIN library_branch lb ON bc.book_copies_BranchID = lb.library_branch_BranchID
WHERE b.book_Title = 'The Lost Tribe'
GROUP BY lb.library_branch_BranchName;


--3--
SELECT borrower_BorrowerName
FROM borrower
WHERE borrower_CardNo NOT IN (
    SELECT DISTINCT book_loans_CardNo
    FROM book_loans
);

--4--

SELECT b.book_Title, bo.borrower_BorrowerName, bo.borrower_BorrowerAddress
FROM books b
JOIN book_loans bl ON b.book_BookID = bl.book_loans_BookID
JOIN borrower bo ON bl.book_loans_CardNo = bo.borrower_CardNo
JOIN library_branch lb ON bl.book_loans_BranchID = lb.library_branch_BranchID
WHERE lb.library_branch_BranchName = 'Sharpstown' AND bl.book_loans_DueDate = '2018-02-03';


--5--

SELECT lb.library_branch_BranchName, COUNT(bl.book_loans_BookID) AS TotalBooksLoaned
FROM library_branch lb
LEFT JOIN book_loans bl ON lb.library_branch_BranchID = bl.book_loans_BranchID
GROUP BY lb.library_branch_BranchName;

--6--

SELECT borrower_BorrowerName, borrower_BorrowerAddress, COUNT(book_loans_BookID) AS NumberOfBooksCheckedOut
FROM borrower
JOIN book_loans ON borrower.borrower_CardNo = book_loans.book_loans_CardNo
GROUP BY borrower_BorrowerName, borrower_BorrowerAddress
HAVING COUNT(book_loans_BookID) > 5;

--7--

SELECT b.book_Title, COUNT(bc.book_copies_CopiesID) AS NumberOfCopies
FROM books b
JOIN book_copies bc ON b.book_BookID = bc.book_copies_BookID
JOIN authors a ON b.book_BookID = a.book_authors_BookID
JOIN library_branch lb ON bc.book_copies_BranchID = lb.library_branch_BranchID
WHERE a.book_authors_AuthorName = 'Stephen King' AND lb.library_branch_BranchName = 'Central'
GROUP BY b.book_Title;
