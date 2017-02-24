       ctl-opt NoMain;

      //---------------------------------------------------------
      //  Files
      //---------------------------------------------------------

       dcl-f CUSTSUMS UsrOpn;
       dcl-f ORDERS usage(*OUTPUT) UsrOpn;


      //---------------------------------------------------------
      //  Prototypes
      //---------------------------------------------------------

      /copy RPGUNIT1,TESTCASE

      // Program under test.
       Dcl-pr SumByCust ExtPgm('SUMBYCUST') end-pr;

      // Test case prototypes.
       Dcl-pr test_one_customer_one_order end-pr;


      //---------------------------------------------------------
      //  Test Case Definitions
      //---------------------------------------------------------

       dcl-proc test_one_customer_one_order export;
       Dcl-pi test_one_customer_one_order;
       end-pi;

      // Setup.

         clrpfm('ORDERS');
         clrpfm('CUSTSUMS');

         open ORDERS;
         ORDERID = 1;
         CUSTID = 'A001';
         ORDERAMT = 1000;
         write ORDER;
         close ORDERS;

      // Run.

         SumByCust();

      // Check.

         open CUSTSUMS;
         read CUSTSUM;
         assert( not %eof : 'Le fichier CUSTSUMS ne devrait pas être vide' );
         aEqual( 'A001' : CUSTID );
         iEqual( 1000 : SUM );
         close CUSTSUMS;


       end-proc;
