-- Cleaning Data Using SQL queries

SELECT * 
from NashvilleHousing
------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardizing the date format

SELECT SalesDateConverted, Convert(date, SaleDate)
from NashvilleHousing

ALTER TABLE NashvilleHousing 
ADD SalesDateConverted date
update NashvilleHousing
set SalesDateConverted = CONVERT(date, SaleDate)

------------------------------------------------------------------------------------------------------------------------------------------------------

--Populate property Address Data

SELECT *
from NashvilleHousing
ORDER BY ParcelID

-- if there 2 same ParcelID and one of them does not have an address, then copy the address from duplicate ParcelId and paste it in another
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking Address in to seperate columns (Address, City, State)
-- For property address
SELECT PropertyAddress
from NashvilleHousing

SELECT
SUBSTRING(propertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(propertyAddress,  CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as address
From NashvilleHousing

ALTER TABLE NashvilleHousing 
ADD propertySplitAddress Nvarchar(255)
update NashvilleHousing
set propertySplitAddress = SUBSTRING(propertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE NashvilleHousing 
ADD propertySplitCity Nvarchar(255)
update NashvilleHousing
set propertySplitCity = SUBSTRING(propertyAddress,  CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- For Owner address
SELECT OwnerAddress
from NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from NashvilleHousing

ALTER TABLE NashvilleHousing 
ADD OwnerSplitAddress Nvarchar(255)
update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing 
ADD OwnerSplitCity Nvarchar(255)
update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing 
ADD OwnerSplitState Nvarchar(255)
update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
from NashvilleHousing

------------------------------------------------------------------------------------------------------------------------------------------------------
-- Chaging Y and N to yes and noo in Sold as vacant column

SELECT distinct(SoldAsVacant)
from NashvilleHousing

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 END
from NashvilleHousing

Update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 END


------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
with RowNumCTE as(
select *,
ROW_NUMBER() over(
Partition By ParcelId, 
			 PropertyAddress,
			 Saleprice,
			 SaleDate, 
			 LegalReference
			 order by 
				UniqueID
				)row_num
from NashvilleHousing
)
delete
from RowNumCTE
where row_num > 1


------------------------------------------------------------------------------------------------------------------------------------------------------
-- deleting unused columns
SELECT * 
from NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress
alter table NashvilleHousing
drop column SaleDate