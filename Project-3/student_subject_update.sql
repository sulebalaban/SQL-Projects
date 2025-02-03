CREATE DATABASE StudentManagement;
USE StudentManagement;

CREATE TABLE SubjectAlloments ( 
 StudentId VARCHAR(50),
 SubjectId VARCHAR(50),
 Is_Valid BIT(1)
 );
 
 INSERT INTO SubjectAlloments (StudentId,SubjectId,Is_Valid) VALUES
('159103036', 'PO1491', 1),
('159103036', 'PO1492', 0),
('159103036', 'PO1493', 0),
('159103036', 'PO1494', 0),
('159103036', 'PO1495', 0);

CREATE TABLE SubjectRequest (
 StudentId VARCHAR(50),
 SubjectId VARCHAR(50)
 );
 
INSERT INTO SubjectRequest (StudentID, SubjectID) VALUES
('159103036', 'PO1496');

 
DELIMITER $$

CREATE PROCEDURE ProcessSubjectRequest()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE StudentID VARCHAR(50);
    DECLARE RequestedSubjectID VARCHAR(50);
    DECLARE CurrentSubjectID VARCHAR(50);

   
    DECLARE request_cursor CURSOR FOR
    SELECT StudentID, SubjectID FROM SubjectRequest;

  
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN request_cursor;

    read_loop: LOOP
        FETCH request_cursor INTO StudentID, RequestedSubjectID;

        IF done THEN
            LEAVE read_loop;
        END IF;

       
        SELECT SubjectID INTO CurrentSubjectID
        FROM SubjectAllotments
        WHERE StudentID = StudentID AND Is_Valid = 1
        LIMIT 1;

        IF CurrentSubjectID IS NOT NULL THEN
            IF CurrentSubjectID <> RequestedSubjectID THEN
               
                UPDATE SubjectAllotments
                SET Is_Valid = 0
                WHERE StudentID = StudentID AND Is_Valid = 1;

               
                INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
                VALUES (StudentID, RequestedSubjectID, 1);
            END IF;
        ELSE
            
            INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
            VALUES (StudentID, RequestedSubjectID, 1);
        END IF;

    END LOOP;

    CLOSE request_cursor;

    
    TRUNCATE TABLE SubjectRequest;

END $$

DELIMITER ;

 CALL ProcessSubjectRequest();
 