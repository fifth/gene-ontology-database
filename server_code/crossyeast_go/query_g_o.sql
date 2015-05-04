select
  d.gene_label,
  d.gene_desc,
  g_o.go,
  g_o.go_signif,
  o.go_type,
  o.go_name,
  o.go_desc
from
  (
    select
      *
    from
      {db_desc}
    where
      gene_label in {gene_list} or
      id in {gene_list}
  ) as d,
  (
    select
      *
    from
      {db_onto}
    {go_signif}
  ) as g_o,
  (
    select
      *
    from
      go_term_desc
    where
      go_type in {go_type}
  ) as o
where
  d.id = g_o.id and
  g_o.go = o.go
