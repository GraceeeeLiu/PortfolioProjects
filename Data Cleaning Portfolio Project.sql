/*

Cleaning Data in SQL Queries

*/



USE PortfolioProject;
select *
from nashvillehousing;
-- --------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
select SaleDate
from nashvillehousing;

 -- Add new column "NewSaleDate"
ALTER TABLE nashvillehousing
ADD COLUMN SaleDate Date;

UPDATE nashvillehousing 
SET NewSaleDate = STR_TO_DATE(SaleDate, '%M %e, %Y');

update nashvillehousing n
join nashvillehousingog a
on n.UniqueID = a.UniqueID
set n.SaleDate = a.SaleDate;


 -- Drop the column
ALTER TABLE nashvillehousing
DROP COLUMN NewSaleDate;




-- ------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
UPDATE nashvillehousing
SET PropertyAddress = Null
where length(PropertyAddress) = 0;


select * 
from nashvillehousing
where PropertyAddress  is Null;



select * 
from nashvillehousing
order by ParcelID;


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, coalesce(null,b.PropertyAddress)
from nashvillehousing a
join nashvillehousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID != b.UniqueID
where a.PropertyAddress is null;

-- update the null with value
update nashvillehousing a
join nashvillehousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID != b.UniqueID
set a.PropertyAddress = coalesce(null,b.PropertyAddress)
where a.PropertyAddress is null;



-- ------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


select PropertyAddress
from nashvillehousing;

-- SUBSTRING(string,start_position);
-- SUBSTRING(string,start_position,length);
select 
	substring(PropertyAddress, 1, locate(',', PropertyAddress) - 1) as Address,
    substring(PropertyAddress, locate(',', PropertyAddress) + 1,length(PropertyAddress)) as Address
from nashvillehousing;



-- Add two more column to splitaddress and city.
ALTER TABLE nashvillehousing
ADD  PropertySplitAddress nvarchar(255) not null;

UPDATE nashvillehousing
SET PropertySplitAddress = substring(PropertyAddress, 1, locate(',', PropertyAddress) - 1);

ALTER TABLE nashvillehousing
ADD  PropertySplitCity nvarchar(255) not null;

UPDATE nashvillehousing
SET PropertySplitCity = substring(PropertyAddress, locate(',', PropertyAddress) + 1,length(PropertyAddress));




select OwnerAddress
from nashvillehousing;

SELECT SUBSTRING_INDEX(OwnerAddress,',',-1)
FROM nashvillehousing;

SELECT 
	SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1) as street,
	SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 2), '.', -1) AS city,
	SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1) as state
FROM nashvillehousing;

-- Add three column for address, city and state 
ALTER TABLE nashvillehousing
ADD  OwnerSplitAddress nvarchar(255);

UPDATE nashvillehousing
SET OwnerSplitAddress = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1);

ALTER TABLE nashvillehousing
ADD  OwnerSplitCity nvarchar(255);

UPDATE nashvillehousing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 2), '.', -1);

ALTER TABLE nashvillehousing
ADD  OwnerSplitState nvarchar(255);

UPDATE nashvillehousing
SET OwnerSplitState = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1);



-- ------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant),count(SoldAsVacant)
from nashvillehousing
group by SoldAsVacant;

select 
	SoldAsVacant,
    case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end as newva
from nashvillehousing;

update nashvillehousing
set SoldAsVacant =  case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end;


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
-- use cte table to store the duplicate data
with RowNumCTE as (
select *, row_number() over (
	partition by ParcelID, PropertyAddress, SalePrice, LegalReference
order by UniqueID)row_num
from nashvillehousing
-- order by ParcelID
)

select *
from RowNumCTE
where row_num > 1;
-- use the CTE to identify the duplicate rows and then delete them from the target table

delete from nashvillehousing 
where UniqueID in(
	select UniqueID
	from RowNumCTE
	where row_num >1);


-- order by PropertyAddress
 
 
-- -------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
from nashvillehousing;


alter table nashvillehousing
drop column OwnerAddress, 
drop column TaxDistrict, 
drop column PropertyAddress;





