update Product set quantity = 1 where Id = 1
go
drop proc if exists buy2
go
create proc buy2 as 
begin
    declare @quantity int
    BEGIN TRAN
        select @quantity = quantity from Product WITH(updlock) where Id = 1
        waitfor delay '0:0:10'
        if @quantity > 0
        begin
            update Product set quantity = quantity - 1 where Id = 1
            select '賣出一樣商品' as msg
        end
        else
        begin
            select '賣完了' as msg
    end
    COMMIT
end
exec buy2