      //---------------------------------------------------------
      //  Files
      //---------------------------------------------------------

       dcl-f CUSTSUMS  usage(*output);
       dcl-f ORDERS;
      //---------------------------------------------------------
      //  Main Procedure
      //---------------------------------------------------------

       read ORDER;

       dow not %eof;
         SUM += ORDERAMT;
         read ORDER;
       enddo;

       write CUSTSUM;

       *inlr = *on;


