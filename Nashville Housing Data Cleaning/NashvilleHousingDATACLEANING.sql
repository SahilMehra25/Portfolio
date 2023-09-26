select *
from [port.project]..NashvilleHousing

--There is a column named SaleDate but it's in date and time format so  I am going to convert it into date by using CONVERT

select SaleDate,convert(Date,SaleDate)
from [port.project]..NashvilleHousing

--Here I am updating the SaleDate column but it was not reflecting in the Table so I decided to do it the other way and Now I have used alter table 
--atfirst I created s column named SaledateConverted and then used update to fill it with SaleDate converted in Date format

update NashvilleHousing
Set SaleDate=CONVERT(Date,SaleDate)


Alter Table NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
Set SaleDateConverted=CONVERT(Date,SaleDate);

update NashvilleHousing
Set SaleDate=SaleDateConverted

select *
from [port.project]..NashvilleHousing


--InPropertyAddress column there few rows with null values.If we take a closer look the ParcelID has duplicates And in some entries the 
--PropertyAddress is not null so we just need to replace the value where PropertyAddress is null with where it is not null

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
 join NashvilleHousing b
   on a.ParcelID=b.ParcelID
   and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


update a
Set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
  on a.ParcelID=b.ParcelID
  and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--separating the address

select propertyaddress
from NashvilleHousing

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(propertyaddress)) as Address
from NashvilleHousing

alter table NashvilleHousing
Add PropertysplitAddress Nvarchar(255)

update NashvilleHousing
set PropertysplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 



alter table NashvilleHousing
Add PropertysplitCity Nvarchar(255)

update NashvilleHousing
Set PropertysplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(propertyaddress)) 


--spliting OwnerAddress
select
PARSENAME(Replace(ownerAddress,',','.'),3),
PARSENAME(Replace(ownerAddress,',','.'),2),
PARSENAME(Replace(ownerAddress,',','.'),1)
from NashvilleHousing



alter table NashvilleHousing
Add OwnersplitAddress Nvarchar(255)

update NashvilleHousing
Set OwnersplitAddress=PARSENAME(Replace(ownerAddress,',','.'),3)
 
 alter table NashvilleHousing
Add OwnersplitCity Nvarchar(255)

update NashvilleHousing
Set OwnersplitCity=PARSENAME(Replace(ownerAddress,',','.'),2)


 alter table NashvilleHousing
Add OwnersplitState Nvarchar(255)

update NashvilleHousing
Set OwnersplitState=PARSENAME(Replace(ownerAddress,',','.'),1)


select SoldAsVacant,
  case  when SoldAsVacant='N' then 'No'
        when SoldAsVacant='Y' then 'Yes'
		ELSE SoldAsVacant
		END
from [port.project]..NashvilleHousing

update NashvilleHousing
set SoldAsVacant=case  when SoldAsVacant='N' then 'No'
        when SoldAsVacant='Y' then 'Yes'
		ELSE SoldAsVacant
		END



select *,
ROW_NUMBER() over (Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
				 uniqueid)rowN
from [port.project]..NashvilleHousing


DELETE a
from(

select *,
ROW_NUMBER() over (Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
				 uniqueid)rowN
from [port.project]..NashvilleHousing)a
where a.rowN>1



--Deleting unused columns

alter table NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate