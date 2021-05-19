create database Deso30__NGUYENCHIMANH
use  Deso30__NGUYENCHIMANH
go

create table Phongkt(
maphong char(10) primary key,
tenday nvarchar(30),
vitri nvarchar(30),
loaiphong nvarchar(30),
tinhtrang nvarchar(30))

create table SINHVIENVAO(
masv char(10) primary key,
maphong char(10),
hoten nvarchar(30),
gioitinh nvarchar(3),
ngaysinh date,
diachi nvarchar(30),
sdt char(10),
malop char(10),
ngaydangki date,
)

create table SINHVIENRA(
masv char(10) primary key,
maphong char(10),
hoten nvarchar(30),
gioitinh nvarchar(3),
ngaysinh date,
diachi nvarchar(30),
sdt char(10),
malop char(10),
ngayra date,
)

create table Hoadonphong(
mahd char(10) primary key,
maphong char(10),
tiendien int,
tiennuoc int,
tienvs int,
tongtien int)

create table Hoadonsv(
mahd char(10) primary key,
masv char(10),
tienphong int,
tienkhac int,
tongtien int
)


