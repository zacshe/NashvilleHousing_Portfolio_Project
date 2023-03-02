SELECT *
FROM Portfolio_Project_NashvilleHousing..Nashville_Housing
ORDER BY 4	
------------------------------------------------ DATA CLEANING ------------------------------------------------

-- Add a new column with standardized date format

ALTER TABLE Portfolio_Project_NashvilleHousing..Nashville_Housing
ADD Sale_Date_Modified DATE

UPDATE Portfolio_Project_NashvilleHousing..Nashville_Housing
SET Sale_Date_Modified = CONVERT(DATE, SaleDate)





-- Slicing [propertyaddress].

SELECT PropertyAddress
FROM Portfolio_Project_NashvilleHousing..Nashville_Housing

-- Slicing by comma to separate the address and the city

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Property_address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress)) AS Property_city
FROM Portfolio_Project_NashvilleHousing..Nashville_Housing

-- Add new columns and update them using the above statement

ALTER TABLE Portfolio_Project_NashvilleHousing..Nashville_Housing
ADD Property_address NVARCHAR(255), 
	Property_city NVARCHAR(255)

UPDATE Portfolio_Project_NashvilleHousing..Nashville_Housing
SET Property_address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
	Property_city = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress))





-- Slicing [owneraddress]

SELECT owneraddress,
PARSENAME(REPLACE(OwnerAddress,',','.'), 3) AS Owner_Address,
PARSENAME(REPLACE(OwnerAddress,',','.'), 2) AS Owner_City,
PARSENAME(REPLACE(OwnerAddress,',','.'), 1) AS Owner_State
FROM Portfolio_Project_NashvilleHousing..Nashville_Housing

-- Add new columns and update them using the above statement

ALTER TABLE Portfolio_Project_NashvilleHousing..Nashville_Housing
ADD Owner_Address NVARCHAR(255),
	Owner_City NVARCHAR(255),
	Owner_State NVARCHAR(255)

UPDATE Portfolio_Project_NashvilleHousing..Nashville_Housing
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
	Owner_City = PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
	Owner_State = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

SELECT * FROM Portfolio_Project_NashvilleHousing..Nashville_Housing





--  Looking for missing [propertyaddress] and decided to replace missing [propertyaddresses] with addresses that share same parcelID

SELECT [UniqueID ], parcelID, PropertyAddress
FROM Portfolio_Project_NashvilleHousing..Nashville_Housing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID

-- Using the select statement to join the table with itself by the same [parcelID] and different [UniqueUD].

SELECT 
	t1.[UniqueID ], t1.ParcelID, t1.PropertyAddress,
	t2.[UniqueID ], t2.ParcelID, t2.PropertyAddress
FROM Portfolio_Project_NashvilleHousing..Nashville_Housing AS t1
JOIN Portfolio_Project_NashvilleHousing..Nashville_Housing AS t2
ON t1.ParcelID = t2.ParcelID AND t1.[UniqueID ] != t2.[UniqueID ]
WHERE t1.PropertyAddress IS NULL

-- Using the update function to replace the left(original) table's [propertyaddress] with the right table's [propertyaddress].

UPDATE t1
SET t1.PropertyAddress = ISNULL(t1.PropertyAddress, t2.PropertyAddress)
FROM Portfolio_Project_NashvilleHousing..Nashville_Housing AS t1
JOIN Portfolio_Project_NashvilleHousing..Nashville_Housing AS t2
ON t1.ParcelID = t2.ParcelID AND t1.[UniqueID ] != t2.[UniqueID ]
WHERE t1.PropertyAddress IS NULL





-- Inspect the values in [soldasvacant]

SELECT 
	DISTINCT SoldAsVacant, 
	COUNT(SoldAsVacant)
FROM Portfolio_Project_NashvilleHousing..Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY 2

-- Replace Y and N with Yes and No

UPDATE Portfolio_Project_NashvilleHousing..Nashville_Housing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant END





-- Provide [row_num] to each row based on [ParcelID], [PropertyAddress], [SalePrice], [SaleDate], [LegalReference]. If the [row_num] is
-- greater than 1, meaning that the values in the 5 columns have repeated, there is a duplicate row.

WITH CTE1 AS (
SELECT *, ROW_NUMBER() OVER(
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID
	) Row_Num
FROM Portfolio_Project_NashvilleHousing..Nashville_Housing
)
SELECT *
FROM CTE1
WHERE Row_Num > 1
ORDER BY [UniqueID ]

-- Remove duplicate rows

WITH CTE1 AS (
SELECT *, ROW_NUMBER() OVER(
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID
	) Row_Num
FROM Portfolio_Project_NashvilleHousing..Nashville_Housing
)
DELETE 
FROM CTE1
WHERE Row_Num > 1





-- Drop unneeded columns and rows with too many null values.

ALTER TABLE Portfolio_Project_NashvilleHousing..Nashville_Housing
DROP COLUMN propertyaddress,
			owneraddress,
			ownername,
			taxdistrict

DELETE
FROM Portfolio_Project_NashvilleHousing..Nashville_Housing
WHERE 
	YearBuilt IS NULL AND
	Bedrooms IS NULL AND
	FullBath IS NULL AND
	HalfBath IS NULL