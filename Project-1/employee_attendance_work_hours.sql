CREATE DATABASE attendance_db;
USE attendance_db;

CREATE TABLE employee_attendance (
EmpID INT,
Name VARCHAR(50),
CheckInOutTime DATETIME,
Attendance CHAR(3)
);

INSERT INTO employee_attendance (EmpID,Name,CheckInOutTime,Attendance)
VALUES 
    (1, 'Him', '2024-01-03 10:08', 'IN'),
    (2, 'Raj', '2024-01-03 10:10', 'IN'),
    (3, 'Anu', '2024-01-03 10:12', 'IN'),
    (1, 'Him', '2024-01-03 11:11', 'OUT'),
    (2, 'Raj', '2024-01-03 12:12', 'OUT'),
    (3, 'Anu', '2024-01-03 12:35', 'OUT'),
    (1, 'Him', '2024-01-03 12:08', 'IN'),
    (2, 'Raj', '2024-01-03 12:25', 'IN'),
    (3, 'Anu', '2024-01-03 12:40', 'IN'),
    (1, 'Him', '2024-01-03 14:12', 'OUT'),
    (2, 'Raj', '2024-01-03 15:12', 'OUT'),
    (3, 'Anu', '2024-01-03 18:35', 'OUT'),
    (1, 'Him', '2024-01-03 15:08', 'IN'),
    (1, 'Him', '2024-01-03 18:08', 'OUT');
    
WITH EmployeeAttendance AS(
 SELECT
   EmpID,
   Name,
   CheckInOutTime,
   Attendance,
   ROW_NUMBER() OVER (PARTITION BY EmpID ORDER BY  CheckInOutTime) AS RowNum
FROM employee_attendance
),

EmployeeLogTimes AS (
   SELECT
        e1.EmpID,
        e1.Name,
        e1.CheckInOutTime AS CheckInTime,
        e2.CheckInOutTime AS CheckOutTime
    FROM EmployeeAttendance e1
    LEFT JOIN EmployeeAttendance e2
    ON e1.EmpID = e2.EmpID AND e1.RowNum = e2.RowNum - 1
    WHERE e1.Attendance = 'IN' AND e2.Attendance = 'OUT'
),

EmployeeWorkHours AS (
    SELECT
        EmpID,
        Name,
        MIN(CheckInTime) AS FirstCheckInTime,
        MAX(CheckOutTime) AS LastCheckOutTime,
        COUNT(CheckOutTime) AS TotalOutCount,
        SUM(TIMESTAMPDIFF(MINUTE, CheckInTime, CheckOutTime)) AS TotalWorkMinutes
    FROM EmployeeLogTimes
    GROUP BY EmpID, Name
)

SELECT
    EmpID,
    Name,
    FirstCheckInTime,
    LastCheckOutTime,
    TotalOutCount,
    CONCAT(FLOOR(TotalWorkMinutes / 60), ':', LPAD(TotalWorkMinutes % 60, 2, '0')) AS TotalWorkHours
FROM EmployeeWorkHours;