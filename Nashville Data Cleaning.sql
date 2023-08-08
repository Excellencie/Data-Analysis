-- Standardize the date
SELECT SaleDate, CONVERT(date,SaleDate) as NSaleDate
FROM dbo.NashvilleData

update NashvilleData
set SaleDate = CONVERT(date,SaleDate) 


alter table nashvilledata
add SaleDateCon date; 

update NashvilleData
set SaleDateCon = CONVERT(date,SaleDate)

-- Replace property address where null

select *
from NashvilleData
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleData as a 
JOIN NashvilleData as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

update a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleData as a 
JOIN NashvilleData as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Breaking the property address column into address, city

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as PropAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as PropCity
from NashvilleData

alter table nashvilledata
add PropAddress nvarchar(255); 

update NashvilleData
set PropAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

alter table nashvilledata
add PropCity nvarchar(255); 

update NashvilleData
set PropCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

-- -- Breaking the property address column into address, city, state

select
PARSENAME(Replace(OwnerAddress,',','.'), 3),
PARSENAME(Replace(OwnerAddress,',','.'), 2),
PARSENAME(Replace(OwnerAddress,',','.'), 1)
from NashvilleData

alter table nashvilledata
add OwnerAddressSplit nvarchar(255); 

update NashvilleData
set OwnerAddressSplit = PARSENAME(Replace(OwnerAddress,',','.'), 3)

alter table nashvilledata
add OwnerCity nvarchar(255); 

update NashvilleData
set OwnerCity = PARSENAME(Replace(OwnerAddress,',','.'), 2)

alter table nashvilledata
add OwnerState nvarchar(255); 

update NashvilleData
set OwnerState = PARSENAME(Replace(OwnerAddress,',','.'), 1)

-- Update SoldAsVacant to have Yes and No as only values instead of Y & N

select distinct(SoldAsVacant), count(SoldAsVacant)
from nashvilledata
group by soldasvacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from NashvilleData

UPDATE NashvilleData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	END;


-- Remove duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From NashvilleData)
DELETE 
FROM RowNumCTE
WHERE row_num > 1


--Delete columns that are not in use
ALTER TABLE NashvilleData
DROP COLUMN PropertyAddress
		,OwnerAddress
		,SalesDateCon -- deleting it because because it's a duplicate
		,TaxDistrict
			

SELECT *
FROM NashvilleData
