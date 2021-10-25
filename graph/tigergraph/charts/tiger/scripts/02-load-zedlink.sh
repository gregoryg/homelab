#!/usr/bin/env bash
# USE GRAPH zedlink
gsql -g zedlink '
BEGIN
CREATE LOADING JOB load_zedlink FOR GRAPH zedlink {
    DEFINE FILENAME account = "/home/tigergraph/mydata/zedlink/account.csv";
    DEFINE FILENAME city = "/home/tigergraph/mydata/zedlink/city.csv";
    DEFINE FILENAME company_industry = "/home/tigergraph/mydata/zedlink/company_industry.csv";
    DEFINE FILENAME state = "/home/tigergraph/mydata/zedlink/state.csv";
    DEFINE FILENAME account_account = "/home/tigergraph/mydata/zedlink/account_account.csv";
    DEFINE FILENAME city_state = "/home/tigergraph/mydata/zedlink/city_state.csv";
    DEFINE FILENAME industry = "/home/tigergraph/mydata/zedlink/industry.csv";
    DEFINE FILENAME account_company = "/home/tigergraph/mydata/zedlink/account_company.csv";
    DEFINE FILENAME company = "/home/tigergraph/mydata/zedlink/company.csv";
    DEFINE FILENAME office_city = "/home/tigergraph/mydata/zedlink/office_city.csv";

    LOAD account to VERTEX Account VALUES (
            $"id",
            $"first_name",
            $"last_name",
            $"email",
            $"gender",
            $"job_title",
            $"salary",
            $"recruitable")
        USING header="true", separator=",";

    LOAD company to VERTEX Company VALUES (
            $"id",
            $"name")
    USING header="true", separator=",";

    LOAD city to VERTEX City VALUES (
            $"id",
            $"name")
    USING header="true", separator=",";

    LOAD state to VERTEX State VALUES (
            $"id",
            $"name")
    USING header="true", separator=",";

    LOAD industry to VERTEX Industry VALUES (
            $"id",
            $"name")
    USING header="true", separator=",";

    LOAD account_account TO EDGE connected_to VALUES (
        $"from_id",
        $"to_id")
    USING header="true", separator=",";

    LOAD company_industry TO EDGE connected_to VALUES (
        $"company_id",
        $"industry_id")
    USING header="true", separator=",";

    LOAD city_state TO EDGE is_in VALUES (
        $"city_id",
        $"state_id")
    USING header="true", separator=",";

    LOAD account_company TO EDGE works_in VALUES (
        $"account_id",
        $"company_id")
    USING header="true", separator=",";

    LOAD office_city TO EDGE located_in VALUES (
        $"company_id",
        $"city_id")
    USING header="true", separator=",";


}
END
'

gsql -g zedlink 'run loading job load_zedlink'
