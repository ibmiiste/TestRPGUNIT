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
       Dcl-pr setUp end-pr;

       Dcl-pr test_one_customer_one_order end-pr;

       Dcl-pr test_two_customer_one_order end-pr;

       Dcl-pr test_two_customers_one_order_each end-pr;

      //---------------------------------------------------------
      //  Test Case Definitions
      //---------------------------------------------------------

       Dcl-Proc setUp Export;
       Dcl-pi SetUp end-pi;


         clrpfm('ORDERS');
         clrpfm('CUSTSUMS');

         open ORDERS;
         ORDERID = 1;
         CUSTID = 'A001';
         ORDERAMT = 1000;
         write ORDER;
         close ORDERS;


       End-Proc;

       Dcl-proc test_one_customer_one_order export;
       Dcl-pi test_one_customer_one_order;
       end-pi;

      // Setup.

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

         dcl-Proc test_one_customer_two_orders export;

         Dcl-pi test_one_customer_two_orders end-pi;


      // Setup.

         open ORDERS;
         ORDERID = 2;
         CUSTID = 'A001';
         ORDERAMT = 2000;
         write ORDER;
         close ORDERS;

      // Run.

         SumByCust();

      // Check.

         open CUSTSUMS;
         read CUSTSUM;
         assert( not %eof : 'Le fichier CUSTSUMS ne devrait pas être vide' );
         aEqual( 'A001' : CUSTID );
         iEqual( 1000+2000 : SUM );
         close CUSTSUMS;


       End-proc;

       Dcl-Proc test_two_customers_one_order_each export;

       Dcl-pi test_two_customers_one_order_each end-pi;


      // Setup.

         open ORDERS;
         ORDERID = 2;
         CUSTID = 'B002';
         ORDERAMT = 2000;
         write ORDER;
         close ORDERS;

      // Run.

         SumByCust();

      // Check.

         open CUSTSUMS;

      // First customer.
         read CUSTSUM;
         assert( not %eof : 'Le fichier CUSTSUMS ne devrait pas être vide' );
         aEqual( 'A001' : CUSTID );
         iEqual( 1000 : SUM );

      // Second customer.
         read CUSTSUM;
         assert( not %eof : 'Le fichier CUSTSUMS ne devrait pas être vide' );
         aEqual( 'B002' : CUSTID );
         iEqual( 2000 : SUM );
         close CUSTSUMS;
       End-Proc;
