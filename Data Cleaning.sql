SELECT *
from Portfolio_Project..[Nashville Housing ]
------------------------------------------------------------------------------------------
-- Standardize Date Format

SELECT salesdateConverted,CONVERT(date,SaleDate)
FROM Portfolio_Project..[Nashville Housing ]

UPDATE Portfolio_Project..[Nashville Housing ]
set SaleDate = CONVERT(date,SaleDate)

ALTER TABLE [Nashville Housing ]
add SaleDateConverted DATE;

update [Nashville Housing ]
set SaleDateConverted = CONVERT(date,saledate)

ALTER TABLE [Nashville Housing]
drop column salesdateConverted

---------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
from Portfolio_Project..[Nashville Housing ]
--where PropertyAddress is NULL
ORDER by ParcelID 

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Project..[Nashville Housing ] a
join Portfolio_Project..[Nashville Housing ] b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is NULL

UPDATE a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Project..[Nashville Housing ] a
join Portfolio_Project..[Nashville Housing ] b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is NULL

----------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns ( Address, City, State)

SELECT PropertyAddress
from Portfolio_Project..[Nashville Housing ]
--where PropertyAddress is NULL
--ORDER by ParcelID 

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
from Portfolio_Project..[Nashville Housing ]
 
 ALTER TABLE [Nashville Housing ]
add PropertySplitAddress nvarchar(255);

update [Nashville Housing ]
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE [Nashville Housing ]
add PropertySplitCity nvarchar(255);

update [Nashville Housing ]
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


SELECT OwnerAddress
from Portfolio_Project..[Nashville Housing ]

SELECT PARSENAME( REPLACE(OwnerAddress, ',', '.'),3)
,PARSENAME( REPLACE(OwnerAddress, ',', '.'),2)
,PARSENAME( REPLACE(OwnerAddress, ',', '.'),1)
from Portfolio_Project..[Nashville Housing ]

ALTER TABLE [Nashville Housing ]
add OwnerSplitAddress nvarchar(255);

update [Nashville Housing ]
set OwnerSplitAddress = PARSENAME( REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE [Nashville Housing ]
add OwnerSplitCity nvarchar(255);

update [Nashville Housing ]
set OwnerSplitCity = PARSENAME( REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE [Nashville Housing ]
add OwnerSplitState nvarchar(255);

update [Nashville Housing ]
set OwnerSplitState = PARSENAME( REPLACE(OwnerAddress, ',', '.'),1)

-------------------------------------------------------------------------------------------------------------------
---Change Y And N to Yes And No

SELECT distinct(SoldAsVacant),COUNT(SoldAsVacant)
from Portfolio_Project..[Nashville Housing ]
GROUP by SoldAsVacant
order by SoldAsVacant

SELECT SoldAsVacant
,CASE when SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     end
from Portfolio_Project..[Nashville Housing ]     
---------------------------------------------------------------------------------------------------------------------------
--Remove Duplicates

with RowNumCTE AS(
SELECT *, 
ROW_NUMBER() OVER(
     PARTITION by 
ParcelID,
PropertyAddress,
SaleDate,
LegalReference
ORDER BY
UNIQUEID
) row_num
from Portfolio_Project..[Nashville Housing ]
--ORDER by ParcelID
)
select *
from RowNumCTE
where row_num > 1

 -------------------------------------------------------------------------------------------------------------------------------------------------
 --Deleting Unused Columns

 SELECT *
 from Portfolio_Project..[Nashville Housing ]

ALTER TABLE Portfolio_Project..[Nashville Housing ]
DROP COLUMN OwnerAddress,PropertyAddress,TaxDistrict

ALTER TABLE Portfolio_Project..[Nashville Housing ]
drop COLUMN SaleDate


