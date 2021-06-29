
SELECT *
FROM Project..NashvilleHousing

--Standardize date format

SELECT SaleDateConverted
FROM Project..NashvilleHousing

UPDATE Project..NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE Project..NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate property address data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Project..NashvilleHousing a
JOIN Project..NashvilleHousing b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL 

UPDATE a
 SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Project..NashvilleHousing a
JOIN Project..NashvilleHousing b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL 

-- Breaking out address into individual columns (Address, city, state) for Property Address

SELECT SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
       SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
FROM Project..NashvilleHousing

ALTER TABLE Project..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE Project..NashvilleHousing
SET PropertySplitAddress = SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE Project..NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE Project..NashvilleHousing
SET PropertySplitCity = SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM Project..NashvilleHousing

-- Breaking out address into individual columns (Address, city, state) for Owner Address

SELECT PARSENAME(REPLACE(OwnerAddress,',', '.'), 3), 
       PARSENAME(REPLACE(OwnerAddress,',', '.'), 2),
	   PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
FROM Project..NashvilleHousing

ALTER TABLE Project..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE Project..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)

ALTER TABLE Project..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE Project..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)

ALTER TABLE Project..NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE Project..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)

SELECT *
FROM Project..NashvilleHousing

--Change Y and N in SoldAsVacant to Yes and No

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Project..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE 
   WHEN SoldAsVacant = 'Y' THEN 'Yes'
   WHEN SoldAsVacant = 'N' THEN 'No'
   ELSE SoldAsVacant
END
FROM Project..NashvilleHousing

UPDATE Project..NashvilleHousing
SET SoldAsVacant = CASE 
   WHEN SoldAsVacant = 'Y' THEN 'Yes'
   WHEN SoldAsVacant = 'N' THEN 'No'
   ELSE SoldAsVacant
END

--Remove duplicates

WITH RowNumCTE AS (
SELECT *,
      ROW_NUMBER() OVER (
	  PARTITION BY ParcelID,
	               PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
				   ORDER BY 
				   UniqueID
				   ) row_num
FROM  Project..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

-- Delete unused columns

ALTER TABLE Project..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

ALTER TABLE Project..NashvilleHousing
DROP COLUMN SaleDate

SELECT *
FROM Project..NashvilleHousing