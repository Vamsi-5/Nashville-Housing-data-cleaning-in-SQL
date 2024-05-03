-- Show the table we are working on
SELECT * FROM nashville_housing;

-- Standard date format 
SELECT SaleDate,CAST(SaleDate AS DATE) AS SaleDate_in_date_format FROM nashville_housing;

-- Update entire saledate column to date 
UPDATE nashville_housing SET SaleDate = CAST(SaleDate AS DATE);

-- Add a column SaleDateConverted 
ALTER TABLE nashville_housing ADD SaleDateConverted DATE;

-- Update the added column to the SaleDate 
UPDATE nashville_housing SET SaleDateConverted = CAST(SaleDate AS DATE);
SELECT * FROM nashville_housing;

-- Populate Property Address data
SELECT PropertyAddress FROM nashville_housing ORDER BY ParcelID;

SELECT N1.ParcelID,N1.PropertyAddress,N2.ParcelID,N2.PropertyAddress,ISNULL(N1.PropertyAddress,N2.PropertyAddress) FROM nashville_housing AS N1,nashville_housing AS N2 
WHERE N1.[UniqueID ] != N2.[UniqueID ] AND N1.ParcelID=N2.ParcelID AND N1.PropertyAddress IS NULL;

UPDATE N1 SET N1.PropertyAddress= ISNULL(N1.PropertyAddress,N2.PropertyAddress)
FROM nashville_housing AS N1 , nashville_housing AS N2 WHERE N1.[UniqueID ] != N2.[UniqueID ] 
AND N1.ParcelID=N2.ParcelID AND N1.PropertyAddress IS NULL;

-- Breaking out address into individual columns (Adress,City,State)
SELECT PropertyAddress FROM nashville_housing;

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) AS Address
FROM nashville_housing;

-- Add two tables 
ALTER TABLE nashville_housing ADD PropertySplitAddress NVARCHAR(255);
ALTER TABLE nashville_housing ADD PropertySplitCity NVARCHAR(255);

-- Update the PropertySplitAddress 
UPDATE nashville_housing SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

-- Update the PropertySplitCity 
UPDATE nashville_housing SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));

SELECT PropertyAddress,PropertySplitAddress,PropertySplitCity FROM nashville_housing;

-- Owneraddress column
SELECT OwnerAddress FROM nashville_housing WHERE OwnerAddress IS NOT NULL;

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),1) FROM nashville_housing WHERE OwnerAddress IS NOT NULL;
SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),2) FROM nashville_housing WHERE OwnerAddress IS NOT NULL;
SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3) FROM nashville_housing WHERE OwnerAddress IS NOT NULL;

-- Add columns for splitting the owneraddress into 

ALTER TABLE nashville_housing ADD OwnerSplitCity NVARCHAR(255);
ALTER TABLE nashville_housing ADD OwnerSplitAddress NVARCHAR(255);
ALTER TABLE nashville_housing ADD OwnerSplitState NVARCHAR(255);

UPDATE nashville_housing SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);
UPDATE nashville_housing SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);
UPDATE nashville_housing SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

SELECT OwnerSplitCity,OwnerSplitState,OwnerSplitAddress FROM nashville_housing WHERE OwnerAddress IS NOT NULL;

-- Change Y and N to Yes and No in 'Sold as Vacant' field
UPDATE nashville_housing SET SoldAsVacant = 'Yes' WHERE SoldAsVacant = 'Y';
UPDATE nashville_housing SET SoldAsVacant = 'No' WHERE SoldAsVacant = 'N';
SELECT DISTINCT SoldAsVacant FROM nashville_housing;

-- Remove duplicates
;WITH CTE_name AS(
SELECT *,ROW_NUMBER() OVER(PARTITION BY 
ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
ORDER BY UniqueID ASC) AS row_number
FROM nashville_housing)
SELECT * FROM CTE_name WHERE row_number>1 ORDER BY PropertyAddress;

ALTER TABLE nashville_housing DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress;