#!/usr/bin/env bash
gsql 'create graph zedlink()'
gsql '
USE GRAPH zedlink
CREATE SCHEMA_CHANGE JOB local_schema_thang FOR GRAPH zedlink {
   ADD VERTEX Account(PRIMARY_ID id INT,
                      first_name STRING,
                      last_name STRING,
                      email STRING,
                      gender STRING,
                      job_title STRING,
                      salary DOUBLE,
                      recruitable BOOL)
   WITH primary_id_as_attribute="true";

   ADD VERTEX Company(PRIMARY_ID id INT,
                      name STRING)
   WITH primary_id_as_attribute="true";

   ADD VERTEX City(PRIMARY_ID id INT,
                      name STRING)
   WITH primary_id_as_attribute="true";

   ADD VERTEX State(PRIMARY_ID id INT,
                      name STRING)
   WITH primary_id_as_attribute="true";

   ADD VERTEX Industry(PRIMARY_ID id INT,
                      name STRING)
   WITH primary_id_as_attribute="true";

   ADD UNDIRECTED EDGE connected_to (FROM Account, TO Account);

   ADD DIRECTED EDGE works_in(FROM Account, TO Company) WITH REVERSE_EDGE="reverse_works_in";

   ADD DIRECTED EDGE in_industry(FROM Company, TO Industry) WITH REVERSE_EDGE="reverse_in_industry";

   ADD DIRECTED EDGE located_in(FROM Company, TO City) WITH REVERSE_EDGE="reverse_located_in";

   ADD DIRECTED EDGE is_in(FROM City, TO State) WITH REVERSE_EDGE="reverse_is_in";

}
'

gsql -g zedlink 'run schema_chage job local_schema_thang'
