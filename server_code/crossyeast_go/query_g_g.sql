select
  p.gene_label as plab, p.gene_desc as pdesc,
  c.gene_label as clab, c.gene_desc as cdesc
from
  (
    select *
    from yeast_homology
    where
      {taxi}_id in (
        select id
        from {fromyeast}
        {restrain}
      )
  ) as h,
  (
    select *
    from sz_pombe_desc
    {prestrain}
  ) as p,
  (
    select *
    from s_cerevisiae_desc
    {crestrain}
  ) as c
where
  c.id = h.cerevisiae_id and
  p.id = h.pombe_id
  