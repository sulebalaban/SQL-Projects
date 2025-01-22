CREATE DATABASE UniversityDB;
USE UniversityDB;


CREATE TABLE StudentDetails(
StudentId INT PRIMARY KEY,
StudentName VARCHAR(200),
GPA FLOAT,
Branch VARCHAR(50),
Section  VARCHAR(5)
);

INSERT INTO StudentDetails (StudentId,StudentName,GPA,Branch,Section)
VALUES
(159103036,'Mohit Agarwal',8.9,'CCE','A'),
(159103037,'Arjun Mehta',5.2,'CCE','A'),
(159103038,'Shohit Garg',7.1,'CCE','B'),
(159103039,'Mrinal Malhotra',7.9,'CCE','A'),
(159103040,'Mehreet Singh',5.6,'CCE','A'),
(159103041,'Arjun Tehlan',9.2,'CCE','B');


CREATE TABLE SubjectDetails(
SubjectId VARCHAR(50) PRIMARY KEY,
SubjectName VARCHAR(200),
MaxSeats INT,
RemainingSeats INT
);

INSERT INTO SubjectDetails(SubjectId,SubjectName,MaxSeats,RemainingSeats)
VALUES
('PO1491','Basics of Political Science',60, 2),
('PO1492','Basics of Accounting',120,119),
('PO1493','Basics of Financial Markets',90,90),
('PO1494','Eco Philosophy',60,50),
('PO1495','Automotive Trens',60,60);


CREATE TABLE StudentPreference(
 StudentId INT,
 SubjectId VARCHAR(50),
 Preference INT,
 FOREIGN KEY(StudentId) REFERENCES StudentDetails(Studentid),
 FOREIGN KEY (Subjectid) REFERENCES SubjectDetails(Subjectid),
 PRIMARY KEY (Studentid, Preference)
);

INSERT INTO StudentPreference(StudentId, SubjectId,Preference)
VALUES
(159103036,'PO1491',1),
(159103036,'PO1492',2),
(159103036,'PO1493',3),
(159103036,'PO1494',4),
(159103036,'PO1495',5);

CREATE TABLE Allotments (
    SubjectId VARCHAR(50),
    StudentId INT,
    PRIMARY KEY (SubjectId, StudentId)
);

CREATE TABLE UnallotedStudents (
    StudentId INT PRIMARY KEY
);

DELIMITER $$

CREATE PROCEDURE AllocateSubjects()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE sid INT;
    DECLARE gpa FLOAT;
    DECLARE pref INT;
    DECLARE subj_id VARCHAR(50);
    DECLARE subj_seats INT;
    DECLARE allocated TINYINT(1);

    -- Declare cursor
    DECLARE cur CURSOR FOR
        SELECT Studentid, GPA
        FROM StudentDetails
        ORDER BY GPA DESC;  -- Yüksek GPA'ya göre sıralama

    -- Declare continue handler for cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO sid, gpa;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SET pref = 1;
        SET allocated = 0;

        -- Bu döngüde sadece PO1491 subject'ini kontrol ediyoruz
        WHILE pref <= 5 AND allocated = 0 DO
            -- Fetch subject preference for the student
            SELECT Subjectid
            INTO subj_id
            FROM StudentPreference
            WHERE Studentid = sid AND Preference = pref
            LIMIT 1;  -- Her öğrenci için sadece 1 tercihini al

            -- Eğer seçilen subject PO1491 ise
            IF subj_id = 'PO1491' THEN
                -- Check remaining seats for the subject
                SELECT RemainingSeats
                INTO subj_seats
                FROM SubjectDetails
                WHERE Subjectid = subj_id;

                -- Allocate subject if seats are available
                IF subj_seats > 0 THEN
                    INSERT INTO Allotments (Subjectid, Studentid)
                    VALUES (subj_id, sid);

                    -- Update the remaining seats
                    UPDATE SubjectDetails
                    SET RemainingSeats = RemainingSeats - 1
                    WHERE Subjectid = subj_id;

                    SET allocated = 1;
                END IF;
            END IF;

            SET pref = pref + 1;
        END WHILE;

        -- If no subject allocated, mark student as unallocated
        IF allocated = 0 THEN
            INSERT INTO UnallotedStudents (Studentid)
            VALUES (sid);
        END IF;

    END LOOP;

    CLOSE cur;
END $$

DELIMITER ;

-- Step 4: Executing the stored procedure
CALL AllocateSubjects();



