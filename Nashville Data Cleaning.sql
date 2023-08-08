-- Standardize the date
SELECT
  SaleDate,
  CONVERT(date, SaleDate) AS NSaleDate
FROM dbo.NashvilleData

UPDATE NashvilleData
SET SaleDate = CONVERT(date, SaleDate)


ALTER TABLE nashvilledata
ADD SaleDateCon date;

UPDATE NashvilleData
SET SaleDateCon = CONVERT(date, SaleDate)

-- Replace property address where null

SELECT
  *
FROM NashvilleData
ORDER BY ParcelID

SELECT
  a.ParcelID,
  a.PropertyAddress,
  b.ParcelID,
  b.PropertyAddress,
  ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleData AS a
JOIN NashvilleData AS b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleData AS a
JOIN NashvilleData AS b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Breaking the property address column into address, city

SELECT
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS PropAddress,
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS PropCity
FROM NashvilleData

ALTER TABLE nashvilledata
ADD PropAddress nvarchar(255);

UPDATE NashvilleData
SET PropAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE Nashvilledata
ADD PropCity nvarchar(255);

UPDATE NashvilleData
SET PropCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

-- -- Breaking the property address column into address, city, state

SELECT
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleData

ALTER TABLE Nashvilledata
ADD OwnerAddressSplit nvarchar(255);

UPDATE NashvilleData
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Nashvilledata
ADD OwnerCity nvarchar(255);

UPDATE NashvilleData
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE nashvilledata
ADD OwnerState nvarchar(255);

UPDATE NashvilleData
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Update SoldAsVacant to have Yes and No as only values instead of Y & N

SELECT DISTINCT
  (SoldAsVacant),
  COUNT(SoldAsVacant)
FROM nashvilledata
GROUP BY soldasvacant
ORDER BY 2

SELECT
  SoldAsVacant,
  CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
  END
FROM NashvilleData

UPDATE NashvilleData
SET SoldAsVacant =
                  CASE
                    WHEN SoldAsVacant = 'Y' THEN 'Yes'
                    WHEN SoldAsVacant = 'N' THEN 'No'
                    ELSE SoldAsVacant
                  END;


-- Remove duplicates

WITH RowNumCTE
AS (SELECT
  *,
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
  PropertyAddress,
  SalePrice,
  SaleDate,
  LegalReference
  ORDER BY
  UniqueID
  ) row_num
FROM NashvilleData)
DELETE FROM RowNumCTE
WHERE row_num > 1


--Delete columns that are not in use
ALTER TABLE NashvilleData
DROP COLUMN PropertyAddress
, OwnerAddress
, SalesDateCon -- deleting it because it's a duplicate
, TaxDistrict


SELECT
  *
FROM NashvilleData
