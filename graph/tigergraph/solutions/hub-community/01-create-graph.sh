#!/usr/bin/env bash
# Load the graph and data

gsql 'create graph Influencers()'

gsql -g Influencers '
create schema_change job influencer_schema for graph Influencers {
       add vertex account (
           PRIMARY_ID account_id INT,
           user_name STRING,
           first_name STRING,
           last_name STRING,
           email STRING,
           gender STRING,
           age INT)
           WITH PRIMARY_ID_AS_ATTRIBUTE = "true";
       add vertex hobby (
           PRIMARY_ID hobby_id INT,
           description STRING)
           WITH PRIMARY_ID_AS_ATTRIBUTE = "true";

         ADD DIRECTED EDGE follows (FROM account, TO account);
         ADD DIRECTED EDGE referred_by (FROM account, TO account, referral_date DATETIME);
         ADD DIRECTED EDGE interested_in (FROM account, TO hobby);
}'

gsql -g Influencers 'run schema_change job influencer_schema'
