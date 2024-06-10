
SELECT * 
FROM [Portfolio Project].dbo.NashvilleHousing;

-- Standardize date format

SELECT SaleDate, CONVERT(date, SaleDate) 
FROM [Portfolio Project].dbo.NashvilleHousing;

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate);

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate);

SELECT * FROM NashvilleHousing;


-- Populate Property Address data WHERE Property Address in Null for the same ParcelID

SELECT a.PropertyAddress, a.ParcelID, b.PropertyAddress, b.ParcelID
FROM NashvilleHousing a
join NashvilleHousing b on a.ParcelID = b.ParcelID and a.UniqueID != b.UniqueID
WHERE a.PropertyAddress is null;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
join NashvilleHousing b on a.ParcelID = b.ParcelID and a.UniqueID != b.UniqueID
WHERE a.PropertyAddress is null;


-- Breaking out Address into Individual Columns (Address, City)

SELECT PropertyAddress
FROM NashvilleHousing;

SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
	   TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))) as City
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = TRIM(SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1));

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)));


-- Other way to break out Address into Individual Columns (Address, City, State)

SELECT OwnerAddress
FROM [Portfolio Project].dbo.NashvilleHousing;

SELECT 
	OwnerAddress, TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)) as Address,
	TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)) as City,
	TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)) as State
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3));

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2));

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1));


-- Change Y and N to Yes and No respectively in "Sold as Vacant" field

SELECT distinct(SoldAsVacant), count(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
	   Case WHEN SoldAsVacant = 'Y' THEN 'Yes'
		    WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant END
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = Case WHEN SoldAsVacant = 'Y' THEN 'Yes'
		    WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant END


-- Remove Duplicates

WITH RowNumCTE AS
	(
SELECT *, 
	ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num
FROM NashvilleHousing
--ORDER BY ParcelID
	)
DELETE
FROM RowNumCTE
WHERE row_num > 1


-- Delete unused columns

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict;

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;
