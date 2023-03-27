SET SERVEROUTPUT ON;
--Part 1 Yu Lee
CREATE OR REPLACE FUNCTION Count_Num_of_Borrowed_Books (STD_ID INT) RETURN INT IS
    books_count INT := 0;
BEGIN
    SELECT COUNT(borrows.borrowID) INTO books_count
        FROM borrows INNER JOIN subscriber_students
        ON subscriber_students.studentid = borrows.studentid
        WHERE borrows.studentid = STD_ID
        GROUP BY name;
    RETURN books_count;
END;
/

BEGIN 
    DBMS_OUTPUT.PUT_LINE(Count_Num_of_Borrowed_Books(1));
END;
--Part 2 Yu Lee
CREATE OR REPLACE PROCEDURE List_Borrow_Information IS
    num_borrowed_books INT := 0;
    
    CURSOR cRENTALS IS
    SELECT subscriber_students.studentID, subscriber_students.name as student_name, subscriber_students.surname, books.name as book_name, borrows.takenDate, book_types.name as booktypes_name
        FROM subscriber_students 
        INNER JOIN borrows ON borrows.studentId = subscriber_students.studentId
        INNER JOIN books ON books.bookId = borrows.bookId 
        INNER JOIN book_types ON book_types.typeId = books.typeId;
        
    cRENT cRENTALS%ROWTYPE;
BEGIN
    FOR cRENT IN cRENTALS LOOP
     num_borrowed_books := Count_Num_of_Borrowed_Books(cRENT.studentId);
    IF num_borrowed_books >20 THEN
   
        DBMS_OUTPUT.PUT_LINE ('Student Name: ' || RPAD(cRENT.student_name,20,' ') || 'Surname: ' || RPAD(cRENT.surname,20,' ') || 'Book Name: ' || RPAD(cRENT.book_name,20,' ')
        || LPAD('Date Taken: ',20,' ') || RPAD(cRENT.takenDate,20,' ') || 'Type Name: ' || RPAD(cRENT.booktypes_name,20,' ') || 'Number of books borrowed: ' || num_borrowed_books);
END IF;
    END LOOP;
END;
/
Begin
    List_Borrow_Information;
END;
--Part 3 Yu Lee
CREATE OR REPLACE PACKAGE Library_Rental_Pkg IS
    PROCEDURE List_Borrow_Information;
    FUNCTION Count_Num_of_Borrowed_Books (STD_ID INT) RETURN INT;
END Library_Rental_Pkg;
/

CREATE OR REPLACE PACKAGE BODY Library_Rental_Pkg IS
    PROCEDURE List_Borrow_Information IS
    
        num_borrowed_books INT := 0;
    
        CURSOR cRENTALS IS
        SELECT subscriber_students.studentID, subscriber_students.name as student_name, subscriber_students.surname, books.name as book_name, borrows.takenDate, book_types.name as booktypes_name
            FROM subscriber_students 
            INNER JOIN borrows ON borrows.studentId = subscriber_students.studentId
            INNER JOIN books ON books.bookId = borrows.bookId 
            INNER JOIN book_types ON book_types.typeId = books.typeId;
            
        cRENT cRENTALS%ROWTYPE;
    BEGIN
        FOR cRENT IN cRENTALS LOOP
         num_borrowed_books := Count_Num_of_Borrowed_Books(cRENT.studentId);
        IF num_borrowed_books >20 THEN
       
            DBMS_OUTPUT.PUT_LINE ('Student Name: ' || RPAD(cRENT.student_name,20,' ') || 'Surname: ' || RPAD(cRENT.surname,20,' ') || 'Book Name: ' || RPAD(cRENT.book_name,20,' ')
        || LPAD('Date Taken: ',20,' ') || RPAD(cRENT.takenDate,20,' ') || 'Type Name: ' || RPAD(cRENT.booktypes_name,20,' ') || 'Number of books borrowed: ' || num_borrowed_books);
    END IF;
        END LOOP;
    END;
    
    FUNCTION Count_Num_of_Borrowed_Books (STD_ID INT) RETURN INT IS
            books_count INT := 0;
    BEGIN
        SELECT COUNT(borrows.borrowID) INTO books_count
            FROM borrows INNER JOIN subscriber_students
            ON subscriber_students.studentid = borrows.studentid
            WHERE borrows.studentid = STD_ID
            GROUP BY name;
        RETURN books_count;
    END;
END Library_Rental_Pkg;
/
EXECUTE Library_Rental_Pkg.List_Borrow_Information;
/
--Part 4 Yu Lee
DROP TABLE students_Log;

CREATE TABLE Students_Log (
    STUDENTID NUMBER NOT NULL,
    USERNAME VARCHAR2(30) NOT NULL,
    ACTION CHAR NOT NULL,
    ACTION_TIME TIMESTAMP NOT NULL,
    
    OLD_NAME VARCHAR(20),
    OLD_SURNAME VARCHAR(20),
    OLD_BIRTHDATE DATE,
    OLD_GENDER VARCHAR(10),
    OLD_CLASS VARCHAR(7),
    OLD_POINT INT,
    
    NEW_NAME VARCHAR(20),
    NEW_SURNAME VARCHAR(20),
    NEW_BIRTHDATE DATE,
    NEW_GENDER VARCHAR(10),
    NEW_CLASS VARCHAR(7),
    NEW_POINT INT
);

CREATE OR REPLACE TRIGGER TRG_STUDENTS_LOGGER
AFTER INSERT OR UPDATE OR DELETE ON subscriber_students
FOR EACH ROW
DECLARE
    STUDENT_ID NUMBER;
BEGIN
    IF (UPDATING) THEN
        INSERT INTO Students_Log(STUDENTID, USERNAME, ACTION, ACTION_TIME,
            OLD_NAME, OLD_SURNAME, OLD_BIRTHDATE, OLD_GENDER,
            OLD_CLASS, OLD_POINT, NEW_NAME, NEW_SURNAME, NEW_BIRTHDATE,
            NEW_GENDER, NEW_CLASS, NEW_POINT)
        VALUES (:OLD.studentId, USER, 'U', SYSTIMESTAMP,
            :OLD.name, :OLD.surname, :OLD.birthdate, :OLD.gender,
            :OLD.class, :OLD.point, :NEW.name, :NEW.surname, :NEW.birthdate,
            :NEW.gender, :NEW.class, :NEW.point);
    ELSIF (INSERTING) THEN
        INSERT INTO Students_Log(STUDENTID, USERNAME, ACTION, ACTION_TIME,
            NEW_NAME, NEW_SURNAME, NEW_BIRTHDATE, NEW_GENDER,
            NEW_CLASS, NEW_POINT)
        VALUES (:NEW.studentId, USER, 'I', SYSTIMESTAMP,
            :NEW.name, :NEW.surname, :NEW.birthdate, :NEW.gender,
            :NEW.class, :NEW.point);
    ELSIF (DELETING) THEN
        INSERT INTO Students_Log(STUDENTID, USERNAME, ACTION, ACTION_TIME,
            OLD_NAME, OLD_SURNAME, OLD_BIRTHDATE, OLD_GENDER,
            OLD_CLASS, OLD_POINT)
        VALUES (:OLD.studentId, USER, 'D', SYSTIMESTAMP,
            :OLD.name, :OLD.surname, :OLD.birthdate, :OLD.gender,
            :OLD.class, :OLD.point);
    END IF;
END;
/
INSERT INTO subscriber_students (studentId, name, surname, birthdate, gender, class, point) 
VALUES (600, 'Payto', 'Parker', TO_DATE('2000-07-04', 'YYYY-MM-DD'), 'F', '9E', 76);
UPDATE subscriber_students SET name = 'Steve Jobs' WHERE studentId = 600;
DELETE from subscriber_students WHERE studentId = 600;
