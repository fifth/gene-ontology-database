select des.gene_label, des.gene_desc
from
  (
    select distinct
      id, count(go in ({go_list})) as cnt
    from (
      select distinct id, go
      from {taxi}_go
    ) mer
    group by id
  ) as res,
  {taxi}_desc as des
where res.cnt = {lengthgo} and des.id = res.id
