-- update Product set quantity = 1 where Id = 1
-- go
-- drop proc if exists buy
-- go
-- create proc buy as begin
--     declare @quantity int
--     select @quantity = quantity from Product where Id = 1
--     waitfor delay '0:0:10'
--     if @quantity > 0
--     begin
--         update Product set quantity = quantity - 1 where Id = 1
--         select '賣出一樣商品' as msg
--     end
--     else
--     begin
--         select '賣完了' as msg
--     end
-- end

-- EXEC buy
-- select * FROM product


update Product set quantity = 1 where Id = 1
go
-- drop proc if exists buy1
-- go
-- create proc buy1 as begin
--     declare @quantity int

--     begin tran
--         update Product set quantity = quantity - 1 where Id = 1
--         select @quantity = quantity from Product where Id = 1
--         -- waitfor delay '0:0:5'
--         if @quantity >= 0
--         begin
--             select '賣出一樣商品' as msg
--             commit
--         end
--         else
--         begin
--             select '賣完了' as msg
--             rollback
--         end
-- end

EXEC buy1
select * FROM product
