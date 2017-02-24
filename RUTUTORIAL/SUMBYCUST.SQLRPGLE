      //---------------------------------------------------------
      //  Files
      //---------------------------------------------------------

       dcl-f CUSTSUMS  usage(*output);
       dcl-f ORDERS;

      //---------------------------------------------------------
      //  Global Variables
      //---------------------------------------------------------

      // Current order.
       Dcl-ds orderDS LikeRec(ORDER);
      // Current customer sum.
       Dcl-ds custSumDS LikeRec(CUSTSUM:*output);
      // Customer break indicator.
       Dcl-s custBreak ind;

      //---------------------------------------------------------
      //  Main Procedure
      //---------------------------------------------------------

       read ORDER orderDS;
       clear custSumDS;
       custSumDS.CUSTID = orderDS.CUSTID;

       dow not %eof;
         custBreak = (custSumDS.CUSTID <> orderDS.CUSTID);

         if custBreak;
           write CUSTSUM custSumDS;
           clear custSumDS;
           custSumDS.CUSTID = orderDS.CUSTID;
         endif;

         custSumDS.SUM += orderDS.ORDERAMT;
         read ORDER orderDS;
       enddo;

       write CUSTSUM custSumDS;

       *inlr = *on;
