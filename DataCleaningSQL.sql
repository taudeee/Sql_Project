

-- lets clean the data using sql

--lets check the data-- 

select *
from house;



--lets change the sale data format

select SaleDate, convert(Date, SaleDate)
from house;

-- convert function is helpful in coverting column's data type
-- Update function is helpful to update the change in the table 
-- syntax convert(data_type, column_name)


Update house
Set SaleDate = convert(date, saleDate)



--lets work on property Address data 

--lets check is there any null value


		select PropertyAddress
		from house
		where PropertyAddress is null;

--there are 29 null values 


		select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
		from house a
		join house b
			on a.ParcelID = b.ParcelID
			AND a.[UniqueID] <> b.[UniqueID]
		where a.PropertyAddress is null;



Update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
		from house a
		join house b
			on a.ParcelID = b.ParcelID
			AND a.[UniqueID] <> b.[UniqueID]
		where a.PropertyAddress is null;




--Breaking out Address into Individual columns (Address, City, State)

--if we see an Propertyaddress, it has mixture of add, city and state 

		select PropertyAddress
		from house;



select 
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address,

substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress)) as Address
from house;


alter table house
Add PropertySplitAddress Nvarchar(255);


Update house
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

Alter Table house
Add PropertySplitCity nvarchar(255);


Update house
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress));




--lets check the owneraddress, it is messed up
--lets clean it 


select OwnerAddress
from house;



--lets use persename
--syntax = parsename('objectname', objectpiece)
select 
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from house;


Alter table house
Add OwnerSplitAddress nvarchar(255);


Update house
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);


Alter table house 
add OwnerSplitCity nvarchar(255);


Update house
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2); 

Alter table house 
add OwnerSplitState nvarchar(255);


Update house
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);




--change Y and N to Yes and NO in "sold as vacant " field

select SoldAsVacant ,
	case
		when SoldAsVacant = 0 then 'No'
		when SoldAsVacant = 1 then 'Yes'
		else SoldAsVacant
	end
from house;

update house
set sold_vacant = convert(varchar(25), sold_vacant);

Update house
set sold_vacant = case
		when SoldAsVacant = 0 then 'No'
		when SoldAsVacant = 1 then 'Yes'
		else SoldAsVacant
	end
where sold_vacant is not null;

select *
from house;


Update house
set SoldAsVacant = convert(varchar(255), SoldAsVacant);



--Drop unwanted columns

alter table house
drop column Address;
 



--Remove Duplicates----
with rownum as (
select *,
		row_number() over (
		Partition by ParcelID, 
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
		Order by 
					UniqueID
					) row_num
from house
)

select *
from rownum
where row_num > 1;

--this is to check if there are any duplicates 

 -- (Select *
--from rownum
--where row_num > 1
--order by PropertyAddress;)


--to delete from above result 

select *
from rownum
where row_num > 1;


with rownum as (
select *,
		row_number() over (
		Partition by ParcelID, 
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
		Order by 
					UniqueID
					) row_num
from house
)

Delete 
from rownum
where row_num > 1;



--104  rows are deleted from original data


select *
from house;


--lets delete sold_vacant

Alter table house
Drop column sold_vacant;



--lets deal with soldAsVacant

Select SoldAsVacant, count(SoldAsVacant)
from house
group by soldAsVacant;


--Here 0 represent No and 1 represent yes
--lets change yes and no


--Adding columns 

Alter table house
Add Sold varchar(5);


--
Select *,
	Case
			when SoldAsVacant = 0 then 'NO'
			Else 'Yes'
	end
from house;


Update house
set Sold = Case
			when SoldAsVacant = 0 then 'NO'
			Else 'Yes'
	end
where SoldAsVacant is not null;


Select *
from house;


--we successfully created new column with different values equivalent to 0 and 1.


--here soldasvacant is no use, lets delete it

alter table house
drop column SoldAsVacant;


