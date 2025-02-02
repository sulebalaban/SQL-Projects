CREATE DATABASE IF NOT EXISTS studentallotments;
USE studentallotments;

CREATE TABLE StudentDetails (
    Studentid INT PRIMARY KEY,
    StudentName VARCHAR(255),
    GPA FLOAT,
    Branch VARCHAR(50),
    Section VARCHAR(5)
);

CREATE TABLE SubjectDetails (
    Subjectid VARCHAR(50) PRIMARY KEY,
    SubjectName VARCHAR(255),
    MaxSeats INT,
    RemainingSeats INT
);

CREATE TABLE StudentPreference (
    Studentid INT,
    Subjectid VARCHAR(50),
    Preference INT,
    FOREIGN KEY (Studentid) REFERENCES StudentDetails(Studentid),
    FOREIGN KEY (Subjectid) REFERENCES SubjectDetails(Subjectid),
    PRIMARY KEY (Studentid, Preference)
);

CREATE TABLE Allotments (
    Subjectid VARCHAR(50),
    Studentid INT,
    FOREIGN KEY (Subjectid) REFERENCES SubjectDetails(Subjectid),
    FOREIGN KEY (Studentid) REFERENCES StudentDetails(Studentid)
);

CREATE TABLE UnallotedStudents (
    Studentid INT PRIMARY KEY,
    FOREIGN KEY (Studentid) REFERENCES StudentDetails(Studentid)
);



INSERT INTO StudentDetails (Studentid, StudentName, GPA, Branch, Section)
VALUES
(159103036, 'Mohit Agarwal', 8.9, 'CCE', 'A'),
(159103037, 'Rohit Agarwal', 5.2, 'CCE', 'A'),
(159103038, 'Shohit Garg', 7.1, 'CCE', 'B'),
(159103039, 'Mrinal Malhotra', 7.9, 'CCE', 'A'),
(159103040, 'Mehreet Singh', 5.6, 'CCE', 'A'),
(159103041, 'Arjun Tehlan', 9.2, 'CCE', 'B');

INSERT INTO SubjectDetails (Subjectid, SubjectName, MaxSeats, RemainingSeats)
VALUES
('P01491', 'Basics of Political Science', 60, 2),
('P01492', 'Basics of Accounting', 120, 119),
('P01493', 'Basics of Financial Markets', 90, 90),
('P01494', 'Eco philosophy', 60, 50),
('P01495', 'Automotive Trends', 60, 60);

INSERT INTO StudentPreference (Studentid, Subjectid, Preference)
VALUES
(159103036, 'P01491', 1),
(159103036, 'P01492', 2),
(159103036, 'P01493', 3),
(159103036, 'P01494', 4),
(159103036, 'P01495', 5);

DELIMITER $$

CREATE PROCEDURE AssignStudentsToSubjects()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE sid INT;
    DECLARE subid VARCHAR(50);
    DECLARE pref INT;
    
    -- Cursor to iterate over students sorted by GPA (descending)
    DECLARE student_cursor CURSOR FOR 
        SELECT sp.Studentid, sp.Subjectid, sp.Preference
        FROM StudentPreference sp
        JOIN StudentDetails sd ON sp.Studentid = sd.Studentid
        ORDER BY sd.GPA DESC, sp.Preference ASC;
    
    -- Declare a handler to exit loop
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    -- Create temporary table to track assigned students
    CREATE TEMPORARY TABLE TempAssignedStudents (Studentid INT PRIMARY KEY);
    
    OPEN student_cursor;
    
    read_loop: LOOP
        FETCH student_cursor INTO sid, subid, pref;
        IF done THEN 
            LEAVE read_loop; 
        END IF;
        
        -- Check if student is already assigned
        IF NOT EXISTS (SELECT 1 FROM TempAssignedStudents WHERE Studentid = sid) THEN
            -- Check if the subject has available seats
            IF (SELECT RemainingSeats FROM SubjectDetails WHERE Subjectid = subid) > 0 THEN
                -- Assign student to the subject
                INSERT INTO Allotments (Subjectid, Studentid) VALUES (subid, sid);
                
                -- Decrease remaining seats
                UPDATE SubjectDetails 
                SET RemainingSeats = RemainingSeats - 1 
                WHERE Subjectid = subid;
                
                -- Mark student as assigned
                INSERT INTO TempAssignedStudents (Studentid) VALUES (sid);
            END IF;
        END IF;
    END LOOP;
    
    CLOSE student_cursor;
    
    -- Insert unassigned students into UnallotedStudents table
    INSERT INTO UnallotedStudents (Studentid)
    SELECT sd.Studentid 
    FROM StudentDetails sd
    WHERE NOT EXISTS (
        SELECT 1 FROM Allotments a 
        WHERE a.Studentid = sd.Studentid
    );

    -- Drop temporary table
    DROP TEMPORARY TABLE IF EXISTS TempAssignedStudents;
END $$

DELIMITER ;
