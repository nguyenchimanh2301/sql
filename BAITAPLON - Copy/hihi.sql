--TRIGGER-8

CREATE TRIGGER TG_C8
on BANGDIEM 
for insert,update
as
declare @masv char(10)
declare @mamh char(10)
declare @dl1 float
declare @dl2 float
declare @ki int
set @masv=(select masv from inserted)
set @mamh=(select mamh from inserted)
set @dl1=(select dieml1 from inserted)
set @dl2=(select dieml2 from inserted)

if (exists(select masv from bangdiem where masv =@masv))
begin
if(@dl1<5)
update BANGDIEM set dieml2=@dl2
where masv=@masv and mamh=@mamh
else
begin
set @dl2=null
update BANGDIEM set dieml2=@dl2
where masv=@masv and mamh=@mamh
end
end
else
begin
if(@dl1<5)
insert into BANGDIEM
values(@masv,@mamh,@dl1,@dl2,@ki)
else
begin
set @dl2 = null
insert into BANGDIEM
values(@masv,@mamh,@dl1,@dl2,@ki)
end
end

insert into BANGDIEM
values('10119588','mh12',3,1)
select * from BANGDIEM
update BANGDIEM
set dieml2=7
where masv='10119311'


