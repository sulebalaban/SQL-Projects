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
(159103037,'Rohit Agarwal',5.2,'CCE','A'),
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
('PO1491','Basics of Political Science',60,2),
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
    DECLARE sid INT;
    DECLARE gpa FLOAT;
    DECLARE pref INT;
    DECLARE subj_id VARCHAR(50);
    DECLARE subj_seats INT;
    DECLARE allocated BOOLEAN;
    DECLARE done INT DEFAULT 0;

    DECLARE cur CURSOR FOR 
        SELECT StudentId, GPA 
        FROM StudentDetails
        ORDER BY GPA DESC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    FETCH cur INTO sid, gpa;

    WHILE done = 0 DO
        SET pref = 1;
        SET allocated = FALSE;

        WHILE pref <= 5 AND allocated = FALSE DO
            SELECT SubjectId INTO subj_id
            FROM StudentPreference
            WHERE StudentId = sid AND Preference = pref;

            SELECT RemainingSeats INTO subj_seats
            FROM SubjectDetails
            WHERE SubjectId = subj_id;

            IF subj_seats > 0 THEN
                INSERT INTO Allotments (SubjectId, StudentId)
                VALUES (subj_id, sid);

                UPDATE SubjectDetails
                SET RemainingSeats = RemainingSeats - 1
                WHERE SubjectId = subj_id;

                SET allocated = TRUE;
            ELSE
                SET pref = pref + 1;
            END IF;
        END WHILE;

        IF allocated = FALSE THEN
            INSERT INTO UnallotedStudents (StudentId)
            VALUES (sid);
        END IF;

        FETCH cur INTO sid, gpa;
    END WHILE;

    CLOSE cur;
END$$

DELIMITER ;


