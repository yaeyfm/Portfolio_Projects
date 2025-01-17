--This Query uses Data obtained from Toronto Open Data website
--Used AI to create a Breed List table which includes the Primary Breed and a AI Generated Clean_Breed column with corrected spelling 

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


-- Tableau Dashboard Link: https://public.tableau.com/app/profile/yaely.fermin.mendeztableau/viz/TorontoDogs/Dashboard1#1
