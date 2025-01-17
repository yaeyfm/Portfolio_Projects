----- SQL Project Clean & Explore Data----
--This Project uses a sample Health Data database obtained from kaggle



Select * 
FROM Projects..Healthcare;

--------------------------Clean Raw Data ------------------------------------------------------------
--------------------Clean Patient & Doctor Name----------------------

--Many patient names include prefixes and/or suffixess, which are not standard across all names. 
--In addition the Names are written with ramdon letter case. The following code explores the names, clean the names and create a new column
--The column Doctor is also explored and cleaned

	Select Distinct(Name)
	FROM Projects..Healthcare
	Order By Name ;


	Select name, PARSENAME(name,2) as prefix
	FROM Projects..Healthcare
	Order by prefix desc;

	Select
	--Find First Word on name
		Distinct(Left (lower(name), Charindex(' ', name +' ') -1 )) as firstwordOnName
		FROM Projects..Healthcare
		Order by firstwordOnName;

	Select
	--Find Last Word on name
		Distinct(Reverse(Left(reverse(Lower(name)), charindex(' ', reverse(name) + ' ') - 1))) as LastWordonName
		FROM Projects..Healthcare
		Order by LastWordonName;

	
	Select  
		(Select String_agg(Upper(Left(value,1))+ Lower(substring(value, 2, Len(value))),' ')
					FROM STRING_SPLIT(LTRIM(RTRIM(LOWER(
						REPLACE(
							Replace(
								Replace(
									Replace(
										Replace(
											Replace(
												Replace(
													Replace(
														Replace(
															Replace(
																Replace(
																	 Replace(
																		Replace(Name, 'ms. ', ''),
																	'mrs. ',''),
																'mr. ',''),
															'dr. ',''),
														' phd',''),
													' jr.',''),
												'miss ',''),
											' dds',''),
										' dvm',''),
									' ii',''),
								' iii',''),
							' iv',''),
						' md','')
					      ))
         ), ' ') AS value
    ) as Clean_Name
	FROM Projects..Healthcare;
	
	--Add New Column for Clean_Name						
	
	Alter Table 	Projects..Healthcare add Clean_Name Nvarchar(100);
	
	--Populate New Column with Clean_Name

	Update Projects..Healthcare 
		Set Clean_Name =
			(Select String_agg(Upper(Left(value,1))+ Lower(substring(value, 2, Len(value))),' ')
					FROM STRING_SPLIT(LTRIM(RTRIM(LOWER(
						REPLACE(
							Replace(
								Replace(
									Replace(
										Replace(
											Replace(
												Replace(
													Replace(
														Replace(
															Replace(
																Replace(
																	 Replace(
																		Replace(Name, 'ms. ', ''),
																	'mrs. ',''),
																'mr. ',''),
															'dr. ',''),
														' phd',''),
													' jr.',''),
												'miss ',''),
											' dds',''),
										' dvm',''),
									' ii',''),
								' iii',''),
							' iv',''),
						' md','')
					      ))
         ), ' ') AS value
    );

	-------------------------Clean Doctor Name-----------------------------------------------
	Select  Doctor,
		(Select String_agg(Upper(Left(value,1))+ Lower(substring(value, 2, Len(value))),' ')
					FROM STRING_SPLIT(LTRIM(RTRIM(LOWER(
						REPLACE(
							Replace(
								Replace(
									Replace(
										Replace(
											Replace(
												Replace(
													Replace(
														Replace(
															Replace(
																Replace(
																	 Replace(
																		Replace(Doctor, 'ms. ', ''),
																	'mrs. ',''),
																'mr. ',''),
															'dr. ',''),
														' phd',''),
													' jr.',''),
												'miss ',''),
											' dds',''),
										' dvm',''),
									' ii',''),
								' iii',''),
							' iv',''),
						' md','')
					      ))
         ), ' ') AS value
    ) as Clean_Doctor
	FROM Projects..Healthcare
	Order by Doctor;
	
	--Add New Column for Clean_Doctor					
	
	Alter Table 	Projects..Healthcare add Clean_Doctor Nvarchar(100);
	
	--Populate New Column with Clean_Doctor

	Update Projects..Healthcare 
		Set Clean_Doctor =
			(Select String_agg(Upper(Left(value,1))+ Lower(substring(value, 2, Len(value))),' ')
					FROM STRING_SPLIT(LTRIM(RTRIM(LOWER(
							REPLACE(
							Replace(
								Replace(
									Replace(
										Replace(
											Replace(
												Replace(
													Replace(
														Replace(
															Replace(
																Replace(
																	 Replace(
																		Replace(Doctor, 'ms. ', ''),
																	'mrs. ',''),
																'mr. ',''),
															'dr. ',''),
														' phd',''),
													' jr.',''),
												'miss ',''),
											' dds',''),
										' dvm',''),
									' ii',''),
								' iii',''),
							' iv',''),
						' md','')
					      ))
         ), ' ') AS value
    );

--------------------------------Reformat Dates------------------------------------------------------------
--Original data format for the dates is date time, but no time is included in the data. Reformating to date to include only relevant information
	Select [Date of Admission] , convert(date, [Date of Admission]), [Discharge Date] , Convert(date,[Discharge Date] )
	FROM Projects..Healthcare

	--Add New Column for Clean Dates				
	
	Alter Table 	Projects..Healthcare add Clean_Date_of_Admission date
	Alter Table 	Projects..Healthcare add Clean_Discharge_Date date

	Update 	Projects..Healthcare
		Set Clean_Date_of_Admission = Convert(date, [Date of Admission])
	Update 	Projects..Healthcare
		Set Clean_Discharge_Date = Convert(date,[Discharge Date] )
	



--------------------------------------Remove Duplicates---------------------------
--Looking for duplicated records
---Using Window function & CTE

	With RowNumCTE as (
	Select *, ROW_NUMBER() OVER (Partition by 
								Clean_Name,
								Age,
								Gender,
								[Blood Type],
								Clean_Doctor,
								Clean_Date_of_Admission,
								Clean_Discharge_Date,
								Hospital,
								[Billing Amount]
							Order by Clean_Name
								) as Row_Num
	FROM Projects..Healthcare
	)

	Delete
	From RowNumCTE
	Where row_num > 1;

------------------------------------Check if Patients are duplicated--------------------------------------------------

		Select Clean_Name, Age, Gender, [Blood Type], [Medical Condition], [Insurance Provider],
		Row_Number () Over (partition by Clean_Name, 
												  Age, 
												  Gender, 
												  [Blood Type], 
												  [Medical Condition],
												  [Insurance Provider]
												  Order by Clean_Name) as Unique_PatientRowCount
	FROM Projects..Healthcare
	Order by Unique_PatientRowCount desc;

	--The totals for Unique_PatientRowCount are all 1, therefore each patient was admitted only once.


---------------------------------- Calculate Admission time  ------------------------------------------------------
	Select DATEDIFF (DAY, [Clean_Date_of_Admission],[Clean_Discharge_Date])   as Days_Admitted,
		  [Clean_Date_of_Admission],[Clean_Discharge_Date]
	FROM Projects..Healthcare

	Alter Table Projects..Healthcare add Days_Admitted INT;

	Update 	Projects..Healthcare
		Set Days_Admitted = DATEDIFF (DAY, [Clean_Date_of_Admission],[Clean_Discharge_Date]) 


-----------------------------------Review Age & create Age Groups for analysis----------------------------------------------------------------

	Select Min(Age), Max(Age), Avg(Age) 
	FROM Projects..Healthcare;

	Select Age, count(age)
	FROM Projects..Healthcare
	Group by Age
	Order by age;

	Select Age, count(age),
		Case 
			when Age between 0 and 14 then '0-14'
			when Age between 15 and 18 then '15-18'
			when Age between 19 and 24 then '19-24' 
			when Age between 25 and 34 then '25-34'
			when Age between 35 and 44 then '35-44'
			when Age between 45 and 54 then '45-54'
			when Age between 55 and 64 then '55-64'
			when Age between 65 and 74 then '65-74'
			when Age between 75 and 84 then '75-84' --There is s significan number of patients between 75 & 85 therfore dedided to breakdown the agegroups one extra level instead of 65+
			when Age >= 85  then '85+'
			else 'Age_group' END
	FROM Projects..Healthcare
	Group by Age
	Order by age;

	Alter Table 	Projects..Healthcare add Age_Group Nvarchar(100)

	Update 	Projects..Healthcare
		Set Age_Group =
						Case 
							when Age between 0 and 14 then '0-14'
							when Age between 15 and 18 then '15-18'
							when Age between 19 and 24 then '19-24' 
							when Age between 25 and 34 then '25-34'
							when Age between 35 and 44 then '35-44'
							when Age between 45 and 54 then '45-54'
							when Age between 55 and 64 then '55-64'
							when Age between 65 and 74 then '65-74'
							when Age between 75 and 84 then '75-84' 
							when Age >= 85  then '85+'
							else 'Age_group' END



-----------------------------------------Biling Analysis-------------------------------------------------------------

	-- Yearly Billing Total and % Change
	WITH YearlyBilling AS (
							SELECT 
								YEAR(Clean_Discharge_Date) AS Billing_Year, 
								SUM([Billing Amount]) AS Yearly_Total
							FROM Projects..Healthcare						
							GROUP BY YEAR(Clean_Discharge_Date)								
							)
	SELECT 	Billing_Year,Yearly_Total,
			Lag(Yearly_Total,1) OVER (ORDER BY Billing_Year) AS Previous_YearBilling,
			((Yearly_Total - Lag(Yearly_Total,1) OVER (ORDER BY Billing_Year))
			/Lag(Yearly_Total,1) OVER (ORDER BY Billing_Year))*100 as Percent_Change

	FROM YearlyBilling
	ORDER BY Billing_Year ;

	-- Billing Data Grouped by Test Results

		Select distinct([Test Results]), 
		   Count(Distinct(CONCAT(Clean_Name, Age, [Blood Type], Gender))) as Unique_Patient_Count,
		   Sum([Billing Amount]) as Total_Billing
	FROM Projects..Healthcare
	Group by [Test Results]
	Order By Total_Billing Desc;

		--Data Grouped by Medical Condition
	With TotalPatientCountCTE as (
							Select
							  Count(Distinct(CONCAT(Clean_Name, Age, [Blood Type], Gender ))) as Total_Unique_Patient
							From Projects..Healthcare
							 )
				,
					TotalBilledCTE as(
						Select Sum([Billing Amount]) as Sum_Total_Billing
						From Projects..Healthcare
								 )

	Select [Medical Condition], Sum(Days_Admitted) as Total_Days_Admitted, 
		   AVG(Days_admitted) as Avg_Days_Admitted,
		   Count(Distinct(CONCAT(Clean_Name, Age, [Blood Type], Gender))) as Unique_Patient_Count,
		   (Cast(Count(Distinct(CONCAT(Clean_Name, Age, [Blood Type], Gender ))) AS float) / Total_Unique_Patient) * 100 as Percentage_Of_Patients,
		   Sum([Billing Amount]) as Total_Billing,
		   (Sum([Billing Amount])/Sum_Total_Billing)*100 as Percentage_Of_Total_Billed

	FROM Projects..Healthcare, TotalPatientCountCTE, TotalBilledCTE
	Group by [Medical Condition], Total_Unique_Patient, Sum_Total_Billing
	Order by Total_Billing Desc;

------------------------------------Patient Focus Analysis-----------------------------------------------------
	--Gender
	With TotalPatientCountCTE as (
							Select
							  Count(Distinct(CONCAT(Clean_Name, Age, [Blood Type], Gender ))) as Total_Unique_Patient
							From Projects..Healthcare
							 )

	Select Gender, Count(Distinct(CONCAT(Clean_Name, Age, [Blood Type], Gender ))) as Unique_Patient, 
	(Cast(Count(Distinct(CONCAT(Clean_Name, Age, [Blood Type], Gender ))) AS float) / Total_Unique_Patient) * 100 as Percentage_Of_Patients
	FROM Projects..Healthcare, TotalPatientCountCTE
	Group by Gender, Total_Unique_Patient;

	-- Age Group
		With TotalPatientCountCTE as (
							Select
							  Count(Distinct(CONCAT(Clean_Name, Age, [Blood Type], Gender ))) as Total_Unique_Patient
							From Projects..Healthcare
							 )
	Select Age_Group, 
		Count(Distinct(CONCAT(Clean_Name, Age, [Blood Type], Gender))) as Unique_Patient,
		(Cast(Count(Distinct(CONCAT(Clean_Name, Age, [Blood Type], Gender ))) AS float) / Total_Unique_Patient) * 100 as Percentage_Of_Patients
	FROM Projects..Healthcare, TotalPatientCountCTE
	Group by Age_Group, Total_Unique_Patient;

	--Blood Type
	Select [Blood Type], Count(Distinct(CONCAT(Clean_Name, Age, [Blood Type], Gender ))) as Unique_Patient_Count
	FROM Projects..Healthcare
	Group by [Blood Type];
