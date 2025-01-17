
--Remove Duplicated from Breed List table 
	With RowNumBreedCTE as (
			Select * , ROW_NUMBER() Over (Partition by Breed Order by Breed) as Row_Number
			From Projects..Dog_Breed_List)
	Delete
	From RowNumBreedCTE 
	Where Row_Number>1
-----------------------------------------------------------------------------------------------
--Clean License Dogs and Cats Table

	Select * 
	From Projects..TO_LicensedDogsandCats;

	Select *
	From Projects..TO_LicensedDogsandCats
	Where ANIMAL_TYPE =	'Dog'
			AND Year < 2025
	Order by Year;

	
	Select PRIMARY_BREED, COUNT(PRIMARY_BREED)
	From Projects..TO_LicensedDogsandCats
	Where ANIMAL_TYPE =		'Dog'
		AND Year < 2025
	Group by PRIMARY_BREED
	Order by PRIMARY_BREED;

-- check for unique ids
	Select _id, Count(_id)
	From Projects..TO_LicensedDogsandCats
	group by _id
	Order by Count(_id) desc

-- Tableau Dashboard Link: https://public.tableau.com/app/profile/yaely.fermin.mendeztableau/viz/TorontoDogs/Dashboard1#1

----Table for Tableau ----Join to obtain Clean_Breed---------------------------------------------------
	Select LDC._id, LDC.Year, LDC.FSA, LDC.ANIMAL_TYPE, LDC.PRIMARY_BREED, DL.Clean_Breed,
			CASE WHEN	DL.Clean_Breed LIKE '% MIX' OR DL.Clean_Breed LIKE 'MIXED%' THEN 'YES'
				 ELSE 'NO' END as Mixed_Breed

	From Projects..TO_LicensedDogsandCats LDC
		LEFT JOIN Projects..Dog_Breed_List DL ON LDC.PRIMARY_BREED = DL.Breed
	Where LDC.ANIMAL_TYPE =	'DOG'
		AND Year < 2025
	Order by _id
	;


-----------------------*******************************************************************************-------------------
--Review Dangerous Dog Order Table

	Select * 
	From Projects..TO_DangerousDogOrder
	Where Year(Date_of_Dangerous_Act) between 2023 and 2024;

---Table for Tableau ----Join to obtain Clean_Breed---------------------------------------------------
	Select  DDG._id,  DDG.Forward_Sortation_Area as FSA, DDG.Name_of_Dog , DDG.Breed, DL.Clean_Breed, 
			CASE WHEN	DL.Clean_Breed LIKE '% MIX' OR DL.Clean_Breed LIKE 'MIXED%' THEN 'YES'
						 ELSE 'NO' END as Mixed_Breed,
			DDG.Bite_Circumstance ,DDG.Location_of_Incident, CAST(DDG.Date_of_Dangerous_Act as Date) as Date_Of_Incident
			

	From Projects..TO_DangerousDogOrder DDG
		LEFT JOIN Projects..Dog_Breed_List DL ON 	DDG.Breed = DL.Breed
	Where Year(Date_of_Dangerous_Act) between 2023 and 2024;





----*************************************-----------

--

	Select * 
	From Projects..TO_DangerousDogOrder
	WHERE --Date_of_Dangerous_Act = '2020-10-02'
	Forward_Sortation_Area like'M9N'
	Order by Forward_Sortation_Area;

	Select * 
	From Projects..TO_LicensedDogsandCats
	Where FSA ='M9N' and 
			PRIMARY_BREED like '%POODLE%'