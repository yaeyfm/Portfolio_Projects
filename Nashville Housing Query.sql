-- Cleaning Data

	Select * 
	From [Covid Project]..[Nashville Housing]

-- Standardize Date
	Select SaleDate , CONVERT(DATE, SaleDate)
	From [Covid Project]..[Nashville Housing]

	Alter Table [Nashville Housing] add SaleDateConverted date;

	Update [Nashville Housing]
	Set SaleDateConverted = CONVERT(DATE, SaleDate)

-- Populate Property address

	Select *
	From [Covid Project]..[Nashville Housing] 
	--where PropertyAddress is null
	order by ParcelID

	Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
	From [Covid Project]..[Nashville Housing] a
	Join [Covid Project]..[Nashville Housing]  b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
	Where a.PropertyAddress is null


	Update a
		SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
		From [Covid Project]..[Nashville Housing] a
			Join [Covid Project]..[Nashville Housing]  b
			ON a.ParcelID = b.ParcelID
			AND a.[UniqueID ]<>b.[UniqueID ]
			Where a.PropertyAddress is null

-- Separating Address into Individual columns (adress, City, State)
	--Property Adress

	SELECT
	SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
	From [Covid Project]..[Nashville Housing]

	--Add new split Addess & City Columns
	Alter Table [Nashville Housing] add PropertySplitAddress Nvarchar(255);

	Update [Nashville Housing]
	Set PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1 )

	Alter Table [Nashville Housing] add PropertySplitCity Nvarchar(255);

	Update [Nashville Housing]
	Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

	Select * 
	From [Nashville Housing]

	--Owner Address

	Select OwnerAddress
	From [Nashville Housing]

	Select
	PARSENAME(Replace (OwnerAddress,',','.') ,3) ,
	PARSENAME(Replace (OwnerAddress,',','.') ,2) ,
	PARSENAME(Replace (OwnerAddress,',','.') ,1) 
	From [Nashville Housing]



	--Add new split Addess Columns
	Alter Table [Nashville Housing] add OwnerSplitAddress Nvarchar(255);

	Update [Nashville Housing]
	Set OwnerSplitAddress = PARSENAME(Replace (OwnerAddress,',','.') ,3);

	Alter Table [Nashville Housing] add OwnerSplitCity Nvarchar(255);

	Update [Nashville Housing]
	Set OwnerSplitCity = PARSENAME(Replace (OwnerAddress,',','.') ,2);

	Alter Table [Nashville Housing] add OwnerSplitState Nvarchar(255);

	Update [Nashville Housing]
	Set OwnerSplitState = PARSENAME(Replace (OwnerAddress,',','.') ,1);

--Change Y & N to Yes & No

	SELECT Distinct(SoldAsVacant), COUNT(soldasvacant)
	From [Nashville Housing]
	Group by SoldAsVacant
	order by 2;

	Select SoldAsVacant ,
	CASE When SoldAsVacant = 'Y' then 'Yes'
		 When SoldAsVacant = 'N' then 'No' 
		 Else SoldAsVacant
		 END
	From [Nashville Housing]
	Where SoldAsVacant = 'Y' or SoldAsVacant = 'N' ;

	Update [Nashville Housing]
	SET soldAsVacant =
						CASE When SoldAsVacant = 'Y' then 'Yes'
							 When SoldAsVacant = 'N' then 'No' 
							 Else SoldAsVacant
							 END
--Remove Duplicates
	--Using Window function & CTE

	With RowNumCTE as (	
	Select *, ROW_NUMBER() OVER (
		Partition by ParcelID,
					 PropertyAddress,
					 SaleDate,
					 SalePrice,
					 LegalReference
					 Order By uniqueID
					 ) row_num
	From [Covid Project]..[Nashville Housing]
	)

	Delete
	From RowNumCTE
	Where row_num > 1;

	
--Delete Unused Columns

	Select * 
	From [Covid Project]..[Nashville Housing];
--
	Alter Table [Covid Project]..[Nashville Housing]
	Drop Column 
			PropertyAddress, Owneraddress, taxdistrict, saledate

	Alter Table [Covid Project]..[Nashville Housing]
	Drop Column saledate