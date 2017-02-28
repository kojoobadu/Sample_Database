/*Drop Table if they exist*/
Drop table if exists Enrollment;
Drop table if exists Offering;
Drop table if exists Person;
Drop table if exists Instructor;
Drop table if exists Student;
Drop table if exists Course;

/* #1 Create the Person table */
Create table Person( Name char (20),
                      ID char (9) not null,
                        Address char (30),
                          DOB date,
                            Primary Key (ID));

/* #2 Create the Instructor table */
Create table Instructor( InstructorID char (9) not null references Person (ID),
                          Rank char (12),
                            Salary int,
                              Primary Key (InstructorID));

/* #3 Create the Student table */
Create table Student( StudentID char (9) not null references Person (ID),
                        Classification char (10),
                          GPA double,
                            MentorID char (9) references Instructor (InstructorID),
                              CreditHours int,
                                Primary Key (StudentID));

/* #4 Create the Course table */
Create table Course ( CourseCode char (6) not null,
                        CourseName char (50) not null,
                            PreReq char (16) not null);

/* #5 Create the Offering table */
Create table Offering ( CourseCode char (6) not null,
                          SectionNo int not null,
                              InstructorID char (9) not null,
                                Primary Key (CourseCode, SectionNo));

/* #6 Create the Enrollment table */
Create table Enrollment ( CourseCode char (6) not null,
                            SectionNo int not null,
                              StudentID char (9) not null references Student,
                                Grade char (4) not null,
                                  Primary Key (CourseCode, StudentID),
                                    Foreign Key (CourseCode, SectionNo) references Offering(CourseCode, SectionNo));

/*Load tables*/
/*# 7*/
load xml local infile "C:/Users/user/Documents/Classes/Spring2017/COM S 363/P2/UniversityXML/Person.xml"
into table Person
rows identified by '<Person>';

/*# 8*/
load xml local infile "C:/Users/user/Documents/Classes/Spring2017/COM S 363/P2/UniversityXML/Instructor.xml"
into table Instructor
rows identified by '<Instructor>';

/*# 9*/
load xml local infile "C:/Users/user/Documents/Classes/Spring2017/COM S 363/P2/UniversityXML/Student.xml"
into table Student
rows identified by '<Student>';

/*# 10*/
load xml local infile "C:/Users/user/Documents/Classes/Spring2017/COM S 363/P2/UniversityXML/Course.xml"
into table Course
rows identified by '<Course>';

/*# 11*/
load xml local infile "C:/Users/user/Documents/Classes/Spring2017/COM S 363/P2/UniversityXML/Offering.xml"
into table Offering
rows identified by '<Offering>';

/*# 12*/
load xml local infile "C:/Users/user/Documents/Classes/Spring2017/COM S 363/P2/UniversityXML/Enrollment.xml"
into table Enrollment
rows identified by '<Enrollment>';


/*# 13 List the IDs of students and the IDs of their Mentors for students who are junior or senior having a GPA above 3.8*/
Select StudentID, MentorID from Student where ( classification = "Senior" or Classification = "Junior") and GPA > 3.8;

/*# 14 List the distinct course codes and sections for courses that are being taken by sophomore. */
Select distinct Enrollment.CourseCode, Enrollment.SectionNo
        from Enrollment
          inner join Student
            on Enrollment.StudentID = Student.StudentID where Student.Classification = "Sophomore";

/*# 15 List the name and salary for mentors of all freshmen. */
Select distinct Person.Name, Instructor.Salary
    from Instructor
      inner join Student
        on Student.MentorID = Instructor.InstructorID and Student.Classification = "Freshman"
          inner join Person
            on Instructor.InstructorID = Person.ID;

/*# 16 Find the total salary of all instructors who are not offering any course.*/
Select distinct Instructor.InstructorID
	from Instructor
		inner join Offering
			on Instructor.InstructorID not in (select Instructor.InstructorID from Offering);


/*# 17 List all the names and DOBs of students who were born in 1976. The expression "Year(x.DOB) = 1976", checks if x is born in the year 1976.*/
Select Person.Name, Person.DOB
	from Person
		inner join Student
			on Person.ID=Student.StudentID where year(Person.DOB) = 1976;

/*# 18 List the names and rank of instructors who neither offer a course nor mentor a student.*/
Select Person.Name, Instructor.rank
  from Offering
    inner join Instructor
      on Instructor.InstructorID not in (Select Instructor.InstructorID from Offering)
        inner join Person
          on Person.ID = Instructor.InstructorID
            inner join Student
              on Instructor.InstructorID not in (Select MentorID from Student);

/*# 19 Find the IDs, names and DOB of the youngest student(s).*/
SELECT Person.Name, Person.DOB
	from Person
		inner join (select min(Person.DOB) y from Person) a
			on a.y = Person.DOB;

/*# 20 List the IDs, DOB, and Names of Persons who are neither a student nor a instructor.*/
Select distinct Person.ID, Person.Name, Person.DOB
  from Student
    inner join Person
      on Person.ID not in (Select Student.StudentID)
        inner join Instructor
          on Person.ID not in (Select Instructor.InstructorID);

/*# 21 For each instructor list his / her name and the number of students he / she mentors.*/
Select InstructorName.Name, count(*) as NumberOfMentees
  from Instructor
    inner join Person as InstructorName
      on InstructorName.ID = Instructor.InstructorID
        inner join Student as Mentee
          on Mentee.MentorID = Instructor.InstructorID
            group by InstructorName.Name;

/*# 22 List the number of students and average GPA for each classification. Your query should not use constants such as "Freshman".*/
Select Classification, count(*) as TotalNumberOfStudents, avg(GPA) as AverageGPAOfStudents
  from Student
    group by Classification;

/*# 23 Report the course(s) with lowest enrollments. You should output the course code and the number of enrollments.*/
Select courseInfo.CourseCode, count(enrollmentInfo.studentid) as NumberOfEnrollments
  from Course courseInfo
    left join Enrollment enrollmentInfo
      on enrollmentInfo.CourseCode = courseInfo.CourseCode
        group by courseInfo.CourseCode
          having count(enrollmentInfo.studentid) = (select count(enrollmentInfo2.studentid)
            from Course courseInfo2
              left join Enrollment enrollmentInfo2
                on enrollmentInfo2.CourseCode = courseInfo2.CourseCode
                  group by courseInfo2.CourseCode
                    order by 1
                      limit 1)
                          order by courseInfo.CourseCode;


/*# 24 List the IDs and Mentor IDs of students who are taking some course, offered by their mentor.*/
Select S.StudentID, S.MentorID
  from Student S
    inner join Enrollment E
      on S.StudentID = E.StudentID
        inner join Offering O
          on E.CourseCode = O.CourseCode
            inner join Instructor I
              on I.InstructorID = O.InstructorID where S.MentorID = I.InstructorID;


/*# 25 List the student id, name, and completed credit hours of all freshman born in or after 1976.*/
Select S.StudentID, P.Name, S.CreditHours
  from Person P
    inner join Student S
      on P.ID = S.StudentID where S.Classification = "Freshman" and (year(P.DOB) = 1976 or year(P.DOB) > 1976);


/*# 26 Insert following information in the database: Student name: Briggs Jason; ID: 480293439; address: 215, North Hyland Avenue; date of birth: 15th January 1975.
He is a junior with a GPA of 3.48 and with 75 credit hours.
His mentor is the instructor with InstructorID 201586985.
Jason Briggs is taking two courses CS311 Section 2 and CS330 Section 1.
He has an ’A’ on CS311 and ’A-’ on CS330.*/
Insert into Person (Name, ID, Address, DOB) values ("Briggs Jason", "480293439", "215, North Hyland Avenue", "1975-01-15 00:00:00");
Insert into Student (StudentID, Classification, GPA, MentorID, CreditHours) values ("480293439", "Junior", 3.48, "201586985", 75);
Insert into Enrollment (CourseCode, SectionNo, StudentID, Grade) values ("CS311", 2, "480293439", "A");
Insert into Enrollment (CourseCode, SectionNo, StudentID, Grade) values ("CS330", 1, "480293439", "A-");

Select * from Person P where P.Name = "Briggs Jason";
Select * from Student S where S.StudentID = "480293439";
Select * from Enrollment E where E.StudentID = "480293439";

/*# 27 Next, delete the records of students from the database who have a GPA less than 0.5.
Note that it is not sufficient to delete these records from Student table; you have to delete them from the Enrollment table first.
(Why?) On the  other hand, do not delete these students from the Person table. */
Delete from Enrollment where StudentID in (
  select * from(
    Select E.StudentID
      from Enrollment E
        inner join Student S
          on E.StudentID = S.StudentID where S.GPA < 0.5) as t);
Delete from Student where GPA < 0.5;


Select * from Student S where S.GPA < 0.5;


/*# 28*/


/*# 29 Insert the following information into the Person table.
Name: Trevor Horns; ID: 000957303; Address: 23 Canberra Street; date of birth: 23rd November 1964.
Then execute the following query:*/
Insert into Person (Name, ID, Address, DOB) values ( "Trevor Horns", "000957303", "23 Canberra Street", "1964-11-23 00:00:00" );
Select * from Person P where P.Name = "Trevor Horns";


/*# 30 Delete the record for Jan Austin from the Person table. If she is a student or an instructor, you should do the deletion with usual care.*/
Delete from Enrollment where StudentID in (
  select * from (
    Select E.StudentID
      from Enrollment E
        inner join Person P
          on E.StudentID = P.ID where P.Name = "Jan Austin") as t
  );

Delete from Student where StudentID in (
    select * from (
      Select P.ID
        from Person P
          inner join Student S
            on P.ID = S.StudentID where P.Name = "Jan Austin") as t
  );

Select * from Person P where P.Name = "Jan Austin";
