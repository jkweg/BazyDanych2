EXPLAIN (ANALYZE, BUFFERS)
select p.productid, p.categoryid, unitprice, av
from products p join
     (select categoryid, avg(unitprice) as av
      from products
      group by categoryid) cav on p.categoryid = cav.categoryid
where unitprice > cav.av;