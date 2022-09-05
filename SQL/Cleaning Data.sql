/*
Cleaning Data in SQL Queries
*/


SELECT*
FROM dbo.NashvilleHousing

-- Standardize Date Format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select saleDateConverted, CONVERT(Date,SaleDate)
From dbo.NashvilleHousing

-- Populate Property Address data

SELECT PropertyAddress
FROM dbo.NashvilleHousing
WHERE PropertyAddress is NULL

-- we need to see why we have some nulls in PropertyAddress column
Select *
From dbo.NashvilleHousing
order by ParcelID

-- Joining the table to itself

SELECT a.ParCelID , a.PropertyAddress, b.ParCelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a 
JOIN dbo.NashvilleHousing b
    ON a.ParCelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a 
JOIN dbo.NashvilleHousing b
    ON a.ParCelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID

Select *
From dbo.NashvilleHousing
WHERE PropertyAddress is NULL

-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress 
From dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress , 1, CHARINDEX(',', PropertyAddress) -1) as Address 
, SUBSTRING(PropertyAddress , CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress , 1, CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE NashvilleHousing
Add City NVARCHAR(255);

Update NashvilleHousing
SET City  = SUBSTRING(PropertyAddress , CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From dbo.NashvilleHousing

Select OwnerAddress
From dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitAddressCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddressCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitAddressState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddressState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From dbo.NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
From dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
From dbo.NashvilleHousing

UPDATE dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END

-- Remove Duplicates

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

From dbo.NashvilleHousing
)

DELETE 
From RowNumCTE
Where row_num > 1

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



-- Delete Unused Columns

Select *
From dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate







