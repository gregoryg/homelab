USE GRAPH influencers
-- 1. Get number of followers for a vertex
CREATE QUERY num_followers(VERTEX <account> p) FOR GRAPH influencers {
  START = {account.*};

  followers= SELECT s
             FROM START:s - (follows:f) - account:a
             WHERE a==p;


PRINT followers.size();
}

-- 2. Get the vertex with the most followers
CREATE QUERY get_influencer() FOR GRAPH influencers {

  SumAccum<INT> @num_followers;
  START = {account.*};

  followers= SELECT a
             FROM START -(follows)- account: a
            ACCUM a.@num_followers += 1
             ORDER BY a.@num_followers DESC
            LIMIT 1;

PRINT followers;
}


--3. Get the top 3 vertices with most followers
CREATE QUERY get_top_3_influencers() FOR GRAPH influencers {

  SumAccum<INT> @num_followers;
  START = {account.*};

  followers= SELECT a
             FROM START -(follows)- account: a
            ACCUM a.@num_followers += 1
             ORDER BY a.@num_followers DESC
            LIMIT 3;

PRINT followers;
}

--4. Get the num of followers by 2 hop for a vertex
CREATE QUERY num_followers_2_hop(VERTEX <account> p ) FOR GRAPH influencers syntax v2 {
  SumAccum<INT> @@num_followers;
  START = {account.*};

  followers= SELECT s
             FROM START:s - (follows>:f) - account:b
             WHERE p==b
                                ACCUM @@num_followers+=1;

followers_2_hop= SELECT s
                 FROM START:s - (follows>:f) - account:b -(follows>:f2)- account:c
                 WHERE p==c
                     ACCUM @@num_followers+=1;


PRINT @@num_followers;
}

-- 5. Get followers for a vertex
CREATE QUERY followers(VERTEX <account> p) FOR GRAPH influencers {
  START = {account.*};

  followers= SELECT s
             FROM START:s - (follows:f) - account:a
             WHERE a==p;


   PRINT followers;
}

-- 6. List all vertices that have been referred by a particular person
-- Example: 516

CREATE QUERY get_referrals(VERTEX <account> p) FOR GRAPH influencers{
    START={account.*};
    referrals= SELECT s
               FROM START:s - (referred_by) -> account:a
               where a==p;

PRINT referrals;

}


--7. list all vertices that follow or have been referred by a particular person
CREATE QUERY get_referrals_followers(VERTEX <account> p) FOR GRAPH influencers{

    SetAccum<vertex<account>> @@referrals_followers;

    START={account.*};

    referrals= SELECT r
               FROM START:r - (referred_by) -> account:a
               where a==p
                POST-ACCUM @@referrals_followers+=r;

    referrals= SELECT f
               FROM START:f - (follows) -> account:a
               where a==p
                POST-ACCUM @@referrals_followers+=f;

    S_Account = { @@referrals_followers };
          PRINT S_Account[
          S_Account.user_name as UserName,
            S_Account.first_name AS FirstName,
            S_Account.last_name AS LastName,
            S_Account.email AS Email,
            S_Account.gender AS Gender
          ];


    PRINT @@referrals_followers;

}



--8. list all vertices that follow or have been referred by a particular person within 2 hops
--Example: 256
CREATE QUERY get_referrals_followers_2_hop(VERTEX <account> p) FOR GRAPH influencers{

    SetAccum<vertex<account>> @@first_level;
    SetAccum<vertex<account>> @@referrals_followers;
    SetAccum<edge<referred_by>> @@ref_links;
    SetAccum<edge<follows>> @@foll_links;

    START={account.*};
    refs= SELECT r FROM START:r - (referred_by:r1) -> account:m where m==p ACCUM @@ref_links+=r1 POST-ACCUM @@first_level+=m;
    foll= SELECT f FROM START:f - (follows:f1) -> account:m where m==p ACCUM @@foll_links+=f1 POST-ACCUM @@first_level+=f;

    lev1={@@first_level};

    referrals= SELECT r
               FROM lev1:r - (referred_by:r1) -> account:m
               ACCUM @@ref_links+=r1
               POST-ACCUM @@referrals_followers+=m;

    followers= SELECT f
           FROM lev1:f - (follows:f1) -> account:m
           ACCUM @@foll_links+=f1
           POST-ACCUM @@referrals_followers+=f;

    S_Account = { @@referrals_followers, @@first_level };

    PRINT @@ref_links;
    PRINT @@foll_links;

    PRINT S_Account[
          S_Account.user_name as UserName,
            S_Account.first_name AS FirstName,
            S_Account.last_name AS LastName,
            S_Account.email AS Email,
            S_Account.gender AS Gender
          ];

}


--9.  list all vertices that follow an influencer, and have a particular interest
-- Example: 1 top influencer, hobby=karaoke
CREATE QUERY get_influencer_followers_hobby(INT top_influencers, STRING interest) FOR GRAPH influencers SYNTAX v2 {

  SumAccum<INT> @num_followers;
  SetAccum<VERTEX<account>> @@list_accounts;
  SetAccum<VERTEX<hobby>> @@hobbies;
  SetAccum<edge<interested_in>> @@in_links;
  SetAccum<edge<follows>> @@foll_links;

  START = {account.*};

  influencer_list= SELECT a
                   FROM START:s -(follows>)- account: a
             ACCUM a.@num_followers += 1
                   ORDER BY a.@num_followers DESC
                                                                              LIMIT top_influencers;

followers_list = SELECT f
                 FROM START:f - (follows>:fl) - influencer_list:i,
                   START:f - (interested_in>:inh) - hobby: h
                 WHERE h.description==interest
                     ACCUM @@list_accounts+=f, @@list_accounts+=i, @@in_links+=inh, @@foll_links+=fl,@@hobbies+=h;


PRINT @@list_accounts;
  PRINT @@in_links;
  PRINT @@foll_links;
  PRINT @@hobbies;


}
