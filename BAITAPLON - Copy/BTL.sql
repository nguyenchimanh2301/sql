use Deso30__NGUYENCHIMANH 
go
--LOGIN
Exec sp_addlogin login11,'11'
Exec sp_addlogin login2
Exec sp_addlogin login3
--tao user
Exec sp_adduser login11,user1
Exec sp_adduser login2,user2
Exec sp_adduser login3,user3
Exec sp_adduser login1,user4
Exec sp_adduser login1,user5
--tao group(database role)
Exec sp_addrole R11
Exec sp_addrole R1
--add user
Exec sp_addrolemember R11,user1
Exec sp_addrolemember R1,user2
Exec sp_addrolemember R1,user3
Exec sp_addrolemember R1,user4
Exec sp_addrolemember R1,user5
--cap quyen
GRANT INSERT,DELETE,UPDATE on sinhvienra to user1 
GRANT INSERT,DELETE,UPDATE on phongkt to user2 
GRANT INSERT,DELETE,UPDATE on hoadonphong to user3
GRANT INSERT,DELETE,UPDATE on hoadonsinhvien to user4
GRANT INSERT,DELETE,UPDATE on hoadonsinhvien to user5

--CHIMUC

create nonclustered index nonclustered_tensv on sinhvienra(hoten)

go
--VIEW
--1 design a view of dorm rooms table
Create view viewdanhsachphong
AS
select * from Phongkt
go
select * from viewdanhsachphong
go
--2 design a view with some atributes of liststudentcomein table
Create view viewdanhsachsvvao
AS
select masv,malop,maphong,hoten,gioitinh,diachi,sdt from SINHVIENVAO
go
select * from viewdanhsachsvvao
go
--3 design a view displays dorm room information about student with code is'10119539'
Create view inforsv
AS
select P.maphong,tenday,loaiphong,tinhtrang,hoten from SINHVIENVAO S inner join Phongkt P
on S.maphong=P.maphong
where masv='10119539'
go
select * from inforsv
go
--4  design a view displays dorm room price about student with bill code is 'hdsv1'
Create view inforhd
AS
select S.masv,tienphong,tienkhac,tongtien=tienphong+tienkhac from SINHVIENVAO S inner join Hoadonsv H
on S.masv=H.masv
where H.mahd='hdsv1'
go
select * from inforhd
go
--5 degin a view displays 
Create view inforview5
AS
select S.masv,hoten,P.maphong,H.mahd,tiendien,tiennuoc,tienvs,tongtien=(tiendien+tiennuoc+tienvs)
from SINHVIENVAO S inner join Phongkt P on S.maphong=P.maphong inner join Hoadonphong H on P.maphong=H.maphong
where H.mahd='hdsv1'
go
select * from inforview5
go
--QUERY
--1 xem danh sách phòng có mã 10
Select * from Phongkt where  maphong like 'phong10_'
--2 Tìm các sinh viên mới vào có quê ở hưng yên
Select * from SINHVIENVAO where diachi like N'Hưng Yên'
--3 Hiển thị phòng đã có sinh viên đăng kí
select * from Phongkt where maphong in(select maphong from SINHVIENVAO)
--4 Đếm số sinh viên phòng 201
select P.maphong,count(masv) as [số lượng sv] from SINHVIENVAO S inner join Phongkt P on P.maphong=S.maphong where P.maphong='phong201'
group by P.maphong
--5 Tìm sinh viên chưa có hóa đơn
Select * from SINHVIENVAO where masv not in (select masv from Hoadonsv) 
--6 Hiển thị sinh viên lớn tuổi nhất
select top(1) *, YEAR(getdate())-YEAR(ngaysinh) as[tuoi] from SINHVIENVAO 
order by tuoi desc
--7 Tính tổng tiền phòng 
select *,(tiendien+tiennuoc+tienvs) as tongtien
from Hoadonphong 
--8 Hiển thị thông tin hóa đơn phòng sinh viên có mã 10119536
select H.* from Hoadonphong H inner join Phongkt P on H.maphong=P.maphong
inner join SINHVIENVAO S on S.maphong=p.maphong
where masv='10119536'
--9 Tính tiền trung bình phải trả của từng sinh viên
Select S.hoten,gioitinh,S.masv,AVG(tienphong+tienkhac) as [trung binh tien]
from Hoadonsv H left join SINHVIENVAO S on S.masv=H.masv
group by S.hoten,gioitinh,S.masv
--10 xếp chuyên ngành cho từng sinh viên
select * ,
(case
when malop='101191'OR malop='101192'OR malop='101181' Then N'Lập trình Web'
when malop='101193'OR malop='101194' Then N'Lập trình Moblie'
when malop='101195'OR malop='101196' Then N'Mạng máy tính'
when malop='101197'OR malop='101198' Then N'IOT'
when malop='101199'OR malop='101190' Then N'Đồ họa'
end
) as N'Chuyên ngành'
from SINHVIENVAO
order by malop asc
go
--PROCDUCE
--1 them du lieu phong
CREATE PROC themphong_pr1 
(
  @maphong char(10),
  @day nvarchar(3),
  @vt nvarchar(30),
  @lp nvarchar(30),
  @tt nvarchar(30))
as
begin
if(exists( select * from Phongkt where maphong=@maphong))
begin
print(N' mã phòng'+@maphong+' đã tồn tại')
rollback tran
end
else
insert into Phongkt
values(@maphong,@day,@vt ,@lp,@tt)
print(N'thêm dữ liệu thành công')
end
go
--2 thêm dữ liệu hóa đơn sinh viên
CREATE PROC themhd_pr2
(
  @mahd char(10),
  @msv nvarchar(3),
  @tp  int,
   @td  int,
    @tn  int,
	@tt int)
as
begin
if(exists(select * from Hoadonsv where mahd=@mahd))
begin
print(N' mã hóa đơn'+@mahd+' đã tồn tại')
rollback tran
end
else
insert into Hoadonsv
values(@mahd,@msv,@tp,@td ,@tn,@tt)
print(N'thêm dữ liệu thành công')
end
go
--3 cập nhật địa chỉ của sinh viên vào

CREATE PROC updatesv_pr3(
@diachi Nvarchar(30),
@msv char(10)
)
as
begin 
if(not exists(select * from SINHVIENVAO where masv=@msv))
begin
print(N'không tồn tại mã sinh viên')
rollback tran
end
else
update SINHVIENVAO 
set diachi=@diachi
WHERE masv=@msv
print(N'sửa thành công')
end
go
--4 Cập nhật thông tin hóa đơn của sinh viên

CREATE PROC updatehdsv_pr4(
@mhd char(10),@tp int,@tk int
)
as
begin 
if(not exists(select * from Hoadonsv where mahd=@mhd))
begin
print(N'không tồn tại mã hóa đơn')
rollback tran
end
else
update Hoadonsv 
set tienphong=@tp,tienkhac=@tk
WHERE mahd=@mhd
print(N'sửa thành công')
end
go 
--5 Xóa thông tin 1 phòng
CREATE PROC del_pr5(
@map char(10)
)
as
begin 
if(not exists(select * from Phongkt where maphong=@map))
begin
print(N'không tồn tại mã phòng')
rollback tran
end
else
DELETE from Phongkt
WHERE maphong=@map
print(N'Xóa thành công')
end
go
--6 Xóa thông tin 1 sinh viên ra
CREATE PROC delsv_pr6(
@msvr char(10)
)
as
begin 
if(not exists(select * from SINHVIENRA where masv=@msvr))
begin
print(N'không tồn tại mã sinh viên')
rollback tran
end
else
DELETE from SINHVIENRA
WHERE masv=@msvr
print(N'Xóa thành công')
end
go 

--7 Tìm Kiếm thông tin sinh viên theo mã phòng
CREATE PROC selectsv_pr7(
@map char(10)
)
as
begin 
if(not exists(select * from Phongkt where maphong=@map))
begin
print(N'không tồn tại mã phòng')
rollback tran
end
else
print(N'THÔNG TIN CẦN TÌM')
Select * from SINHVIENVAO S inner join Phongkt P on S.maphong=P.maphong
WHERE S.maphong=@map
end
go 
--8 Tìm Kiếm thông tin sinh viên theo lớp và địa chỉ
CREATE PROC selectsv_pr8(
@malop char(10),
@diachi nvarchar(30),
@mahd char(10)
)
as
begin 
if(not exists(select * from SINHVIENVAO S inner join Hoadonsv P on S.masv=P.masv where @diachi=diachi or malop=@malop or mahd=@mahd))
begin
print(N'không tồn tại sinh viên có địa chỉ tại'+@diachi+' hoặc mã lớp là'+@malop)
rollback tran
end
else
print(N'THÔNG TIN CẦN TÌM')
Select * from SINHVIENVAO S inner join Hoadonsv P on S.masv=P.masv
WHERE malop=@malop and diachi=@diachi  and @mahd=mahd
end
go 
--9 thống kê số lượng phòng và sinh viên trong kí túc và rời kí túc khóa 2020-2021
CREATE PROC thongke_pr9
as
begin 
declare @slp int,@slsv int, @slsvr int
if(not exists(select maphong from Phongkt))
begin
print(N'không tồn tại phòng kí túc')
rollback tran
end
else
SELECT  @slp = count(maphong) from Phongkt
SELECT  @slsv = count(masv) FROM SINHVIENVAO
SELECT @slsvr = count(masv) from SINHVIENRA 

print(N'thống kê khóa 2020-2021 của KTX trường đại học SPKTHY')
print(N'SÔ PHÒNG:'+cast(@slp as char(3))+'-'+N'SỐ SINH VIÊN VÀO:'+cast(@slsv as char(3))+'-'+N'SỐ SINH VIỂN RA:'+cast(@slsvr as char(3)))
end
go 

EXEC  thongke_pr9
go
--10 thủ tục tính trung bình hóa đơn phòng phải trả
CREATE PROC trungbinh_pr10
as
begin 
declare @ttp int,@td int,@tvs int,@tn int
if(not exists(select mahd from Hoadonphong ))
begin
print(N'không tồn tại mã hd')
rollback tran
end
else
SELECT @td= (SUM(tiendien)/(count(maphong))) from Hoadonphong
SELECT @tn = (SUM(tiennuoc)/(count(maphong)))  from Hoadonphong
SELECT @tvs = (SUM(tienvs)/(count(maphong)))  from Hoadonphong
SELECT @ttp = (@td+@tn+@tvs)
print(N'KTX trường đại học SPKTHY')
print(N'TB tiền điện:'+cast(@td as char(10))+'-'+N'Tiền nước:'+cast(@tn as char(10))+'-'+N'TB Tiền vệ sinh:'+cast(@tvs as char(10))+'-'+N'TB Tổng Tiền:'+cast(@ttp as char(10)))
end
go 
EXEC trungbinh_pr10
go
--FUNCION 
--1 hàm trả về thông tin của sinh viên ra
create FUNCTION  sumtp_f1
(
@masv char(10)
)
returns table
as 
return
(select * from SINHVIENRA 
where masv=@masv
)
drop FUNCTION sumtp_f1
select * from sumtp_f1('10115531')
go

--2 hàm đếm số lượng sinh viên theo mã phòng 
create  function dem_f2( @map char(10))
returns int 
as
begin 
declare @slsv int;
select @slsv = count(masv) from SINHVIENVAO S inner join Phongkt D ON D.maphong=S.maphong
where D.maphong=@map
return(@slsv)
end

select dbo.dem_f2('phong101')
go

--3 hàm trả về thông tin hoa don phòng của 1 mã sinh viên

create function infopsv_f3(@masv char (10))
returns table 
as
return(
select H.* from Hoadonphong H inner join Phongkt P on H.maphong=P.maphong inner join SINHVIENVAO S on S.maphong=P.maphong
where masv=@masv
)
drop function  infopsv_f3
select *  from infopsv_f3('10119539')

GO
--4 Hàm trả về thông tin sinh viên có năm nhập học là 2019
create function inforsv_f4(@date date)
returns table 
as
return
(select * from SINHVIENVAO
where YEAR(ngaydangki)= YEAR(@date)
)

select * from inforsv_f4('2018-01-23')
select * from inforsv_f4('2019-01-23')

go
--5 Hàm Lấy về Họ của các sinh viên theo mã
create function layho_f6(@msv char(10))
returns nvarchar(30)
as 
begin 
declare @KT int
declare @ho nvarchar(30) 
declare @hoten nvarchar(30)
select @hoten = LTRIM(RTRIM(hoten)) from SINHVIENVAO
where masv=@msv
set @KT = CHARINDEX(' ',@hoten)
set @ho = SUBSTRING(@hoten,1,@KT-1)
return @ho
end

select dbo.layho_f6('10119532')
go



--TRIGGER
--1 
create trigger updatesv_t1
on SINHVIENRA
for update
AS
begin
IF update(maphong)
if exists(select * from inserted where maphong not in (select maphong from Phongkt))
begin 
rollback;
throw 50001,'không thể cập nhật vì mã phòng k tồn tại',1;
end
if update(hoten)
if exists(select masv from inserted where (CHARINDEX(' ',TRIM(hoten))<1))
begin
print('eror')
rollback;
throw 50001,N'Không thể cập nhật tên do không đủ 2 kí tự',1;
end
end
go
--2 trigger không được sửa dữ liệu số điện thoại
create trigger delphong_t2 
on SINHVIENVAO
for update 
as
if update(sdt)
begin
print(N'không được sửa dữ liệu số điện thoại')
rollback tran
end

UPDATE SINHVIENVAO set sdt='0123454' where masv='10119539'
go
--3 trigger giới hạn số người theo loại phòng
create trigger insertsv_tg3
on SINHVIENVAO
for insert
as
begin
declare @slsv int
select @slsv = COUNT(masv) from SINHVIENVAO s INNER JOIN Phongkt P on P.maphong=S.maphong
if(@slsv>10)
begin
raiserror(N'Đã đủ số lượng sinh viên',2,1)
rollback
end
else
print('Thêm thành công')
end
go
--4  Trigger instead of delete
create trigger deletesv_tg4
on Phongkt
INSTEAD OF DELETE 
as 
begin 
if(select count(*) from SINHVIENVAO S inner join Phongkt P on 
S.maphong=P.maphong)>0
begin
raiserror('Không xóa được do đã có sinh viên',16,1)
rollback tran
end
else
begin
print'Xóa thành công'
Delete from Phongkt where maphong in (select maphong from deleted)
end
end
go
--5--Trigger instead of insert
Create trigger inserthdsv_tg5
on SINHVIENVAO
INSTEAD OF INSERT 
AS 
begin
if(exists(select D.masv from inserted D ,SINHVIENVAO S where D.masv=S.masv))
begin
raiserror('Đã có mã sinh viên',16,1)
rollback tran
end
if(exists(select masv from inserted where (CHARINDEX(' ',TRIM(hoten))<1)))
begin
raiserror('Họ tên lỗi',16,1)
rollback tran
end
else
if(exists(select masv from inserted where (CHARINDEX(' ',TRIM(diachi))<1)))
begin
raiserror('quê quán lỗi',16,1)
rollback tran
end
end

insert into SINHVIENVAO
values('10119540','phong102',N'Na',N'Nam','1999-01-03',N'ha ada','0566211944','101181','2018-08-19')
go

--6 Trigger after update
Create trigger updatephongkt_tg6
on Phongkt
INSTEAD OF INSERT 
AS 
begin
if( not exists(select D.maphong from inserted D ,Phongkt  S where D.maphong=S.maphong))
begin
raiserror('Không tồn tại mã phòng để update',16,1)
rollback tran
end
if(exists(select vitri from inserted where (CHARINDEX(' ',TRIM(vitri))<1)))
begin
raiserror('Vị trí không được để rỗng',16,1)
rollback tran
end
end

GO
--7 trigger auto update

create trigger autoupdate
on Phongkt
for insert
as 
begin 
update
Phongkt set soluonghientai = soluonghientai+1
where  Phongkt.maphong=(select maphong from SINHVIENVAO)
end

drop trigger autoupdate

select * from Phongkt





ALTER TABLE Phongkt ADD soluonghientai int
ALTER TABLE Phongkt ADD controng int

ALTER TABLE Phongkt DROP COLUMN controng 




update  Phongkt set soluonghientai=0

update Phongkt set soluonghientai=count(masv) 
from SINHVIENVAO inner  join Phongkt P  ON SINHVIENVAO.maphong=P.maphong
where P.maphong=SINHVIENVAO.maphong


create trigger  updatesiso_tg7
on Phongkt  
after insert
as
begin
declare @lsv int =10;
select @lsv=(@lsv-(select count(masv)
from SINHVIENVAO S,inserted D where D.maphong=S.maphong))
update Phongkt set soluonghientai=@lsv
END 

select * from Phongkt
drop trigger updatesiso_tg7


select * from SINHVIENVAO

insert into SINHVIENVAO
values
('10119545','phong101',N'Nguyễn Hữu Hiếu',N'Nam','1999-01-03',N'Hà Nội','0566211944','101181','2018-08-19')