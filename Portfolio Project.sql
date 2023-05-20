
select *
from [Data Cleaning Project].dbo.[Nashville Housing]



-- standardize dates

select SaleDateConverted, convert(Date,SaleDate)
from [Data Cleaning Project].dbo.NashvilleHousing]

update [Nashville Housing]
Set SaleDate - convert(Date,SaleDate)


alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
Set SaleDateConverted = convert(Date,SaleDate)





-- populate property address data

Select *
From [Data Cleaning Project].dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


-- the point is to populate the property address table of all the nulls. So we now use isnull to check if a property address is null, then if it is it uses b property address and sticks it in there
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Data Cleaning Project].dbo.NashvilleHousing a
JOIN [Data Cleaning Project].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- now I am updating that column and populating it with the addresses that we got from b.PropertyAddress into a
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Data Cleaning Project].dbo.NashvilleHousing a
JOIN [Data Cleaning Project].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null







-- Breaking the Address Column into individual Columns (Address, City, State)

Select PropertyAddress
From [Data Cleaning Project].dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

--this helps us to find the commas in the address and get rid of them
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From [Data Cleaning Project].dbo.NashvilleHousing

-- Now I am going to create two new columns 

alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))










-- Splitting up the owner's address column into 3 seperate using a different function tehn creating an actual column in our dataset for the new data we recently split up
select OwnerAddress
From [Data Cleaning Project].dbo.NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) AS OwnerSplitAddress
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) as OwnerSplitCity
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) as OwnerSplitState
From [Data Cleaning Project].dbo.NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) 

alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

alter table NashvilleHousing
add OwnerSplitState Nvarchar(255);

update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)







-- Change Y and N to Yes and No in 'Sold as Vacant' field
-- this function allows me to see how many said yes and no
select distinct(SoldAsVacant), count(SoldAsVacant)
From [Data Cleaning Project].dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		ELSE SoldAsVacant
		END
From [Data Cleaning Project].dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		ELSE SoldAsVacant
		END






-- get rid of duplicates

WITH RowNumCTE AS(
	SELECT *,
	ROW_NUMBER() over (
		Partition By ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
		ORDER BY UniqueID) row_num
From [Data Cleaning Project].dbo.NashvilleHousing
)
Delete
-- select *
from RowNumCTE
Where row_num > 1
-- order by PropertyAddress
-- this function allow us to store all our duplicates in a CTE and then delete them from the dataset, which is not common pratice but good for practice










-- Deleting Unused Columns

Select *
From [Data Cleaning Project].dbo.NashvilleHousing

ALTER TABLE [Data Cleaning Project].dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
-- forgot SaleDate
ALTER TABLE [Data Cleaning Project].dbo.NashvilleHousing
drop column SaleDate
