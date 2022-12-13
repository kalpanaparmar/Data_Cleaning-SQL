/*

Cleaning data in SQL Queries

*/

Select * from Projectportfolio.dbo.NashvilleHousing



--Standardize Date format

Select Saledateconverted, Convert(date, saledate)
from Projectportfolio..NashvilleHousing

Update Projectportfolio..NashvilleHousing
Set Saledate = Convert(date, saledate)

Alter Table NashvilleHousing 
Add SaleDateConverted date;

Update NashvilleHousing
Set SaleDateConverted = Convert(date, saledate)


--Populate Property Address Data

Select *
from Projectportfolio..NashvilleHousing
--Where PropertyAddress is Null


Select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Projectportfolio..NashvilleHousing a
Join Projectportfolio..NashvilleHousing b
     On a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

Update a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Projectportfolio..NashvilleHousing a
Join Projectportfolio..NashvilleHousing b
     On a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null


--Breaking Out Address into Individual columns (Address, city, state)



Select PropertyAddress
from Projectportfolio..NashvilleHousing
--Where PropertyAddress is Null

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
From Projectportfolio..NashvilleHousing

Alter Table Projectportfolio..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update Projectportfolio..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


Alter Table Projectportfolio..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update Projectportfolio..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


Select * 
from Projectportfolio..NashvilleHousing

Select OwnerAddress
from Projectportfolio..NashvilleHousing

Select
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)
From Projectportfolio..NashvilleHousing


Alter Table Projectportfolio..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update Projectportfolio..NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)


Alter Table Projectportfolio..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update Projectportfolio..NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)


Alter Table Projectportfolio..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update Projectportfolio..NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)



--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(Soldasvacant), COUNT(SoldasVacant)
From Projectportfolio..NashvilleHousing
Group by SoldAsVacant
Order By 2


Select SoldAsVacant,
CASE 
	When SoldAsVacant = 'N' Then 'No'
	When SoldAsVacant = 'Y' Then 'Yes'
	Else SoldAsVacant
	End
From Projectportfolio..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = 
CASE 
	When SoldAsVacant = 'N' Then 'No'
	When SoldAsVacant = 'Y' Then 'Yes'
	Else SoldAsVacant
	End




--Remove Duplicates

With RowNumCTE AS( 
Select * ,
	ROW_NUMBER() Over (
	PARTITION BY Parcelid,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					Uniqueid
					) row_num
From Projectportfolio..NashvilleHousing
)
Select * --Delete(deleted the duplicate rows first)
From RowNumCTE
Where row_num >1
Order By Propertyaddress




--Delete Unused Columns

Select * 
From Projectportfolio..NashvilleHousing

Alter Table Projectportfolio..NashvilleHousing
Drop Column OwnerAddress, PropertyAddress, Saledate,TaxDistrict