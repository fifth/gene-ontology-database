# Create database
create database gene_ontology;
use gene_ontology;

# Create tables
create table go_term_desc(
  go int
    primary key not null,
  go_type char(1)
    not null,
  go_name varchar(50),
  go_desc varchar(250)
);

create table sz_pombe_desc (
  id varchar(32)
    primary key not null,
  gene_label varchar(32),
  gene_desc varchar(250)
);

create table s_cerevisiae_desc (
  id varchar(32)
    primary key not null,
  gene_label varchar(32),
  gene_desc varchar(250)
);

create table sz_pombe_go (
  id varchar(32),
  go int,
  go_signif char(3),
  foreign key (id) references sz_pombe_desc(id),
  foreign key (go) references go_term_desc(go)
);

create table s_cerevisiae_go (
  id varchar(32),
  go int,
  go_signif char(3),
  foreign key (id) references s_cerevisiae_desc(id),
  foreign key (go) references go_term_desc(go)
);

create table yeast_homology (
  pombe_id varchar(30),
  cerevisiae_id varchar(30),
  foreign key (pombe_id) references sz_pombe_desc(id),
  foreign key (cerevisiae_id) references s_cerevisiae_desc(id)
);

create table user_results (
  id int
    primary key auto_increment,
  loc varchar(50),
  pw varchar(50),
  laxi char(1),
  summary varchar(250),
  check (laxi in ('C', 'P'))
);

create table user_results_genetic (
  id int,
  genetic varchar(32),
  man char(1),
  foreign key (id) references user_results(id),
  check (man in ('+', '-'))
);

create table user_results_conditional (
  id int,
  conditional varchar(30),
  foreign key (id) references user_results(id)
);
