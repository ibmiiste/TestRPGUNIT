# TestRPGUNIT
Tutorial

    Overview
    Context
    Checking that we are able to write unit tests
    The first test
    Summing orders from the same customer
    Not summing orders from different customers
    Handling customers in any order
    Source code
    Source code in fixed position

Overview

This tutorial will guide you step-by-step through the creation of a small test suite and the implementation of a simple number-summing program. After reading this tutorial, you will know how to write and run RPGUnit tests. You will also learn the basics of TDD .
Context

Let's assume we want to write a simple program (SUMBYCUST) that sums order amounts by customers. There will be an order file (ORDERS) and a customer report file (CUSTSUMS). Start by creating a source file.

	===> CRTSRCPF FILE(RUTUTORIAL) RCDLEN(112) TEXT('RPGUnit - Tutorial.')

Create a PF source member called ORDERS in RUTUTORIAL, with the following description.

	R ORDER              
	  ORDERID        7P 0
	  CUSTID         4A  
	  ORDERAMT      15P 2
			     
	K ORDERID            

Create another PF source member called CUSTSUMS, with the following description.

	R CUSTSUM            
	  CUSTID         4A  
	  SUM           17P 2
			     
	K CUSTID             

Create these two files.

===> CRTPF FILE(ORDERS)   SRCFILE(RUTUTORIAL)
===> CRTPF FILE(CUSTSUMS) SRCFILE(RUTUTORIAL)

Checking that we are able to write unit tests

Before we write any code that is going to last, we want to be sure the testing infrastructure is working correctly. For this, we will write a dummy test. First create an RPGLE source member SUMBYCUSTT in the RUTUTORIAL source file.

    H NoMain                                                    
                                                            
                                                            
     //---------------------------------------------------------
     //  Prototypes                                             
     //---------------------------------------------------------
                                                            
     /copy RPGUNIT1,TESTCASE                                    
                                                            
     // Test case prototypes.                                   
    Dtest_failure     pr                                        
                                                            
                                                            
     //---------------------------------------------------------
     //  Test Case Definitions                                  
     //---------------------------------------------------------
                                                            
    Ptest_failure     b                   Export                
    Dtest_failure     pi                                        
     /free                                                      
                                                            
       iEqual( 5 : 2+2 );                                       
                                                            
     /end-free         
    P                 e

We compile the dummy test.

    ===> RUCRTTST TSTPGM(SUMBYCUSTT) SRCFILE(RUTUTORIAL)

We run it.

    ===> RUCALLTST SUMBYCUSTT
    FAILURE. 1 test case, 1 assertion, 1 failure, 0 error.

The dummy test fails as expected. We can remove it and write our first test.

If you do not get this failure message, something is wrong with your RPGUnit framework installation. Check that the RPGUnit objects are in your library list (e.g., WRKOBJ RU*) and try to run the framework's self-test feature RPGUNITT1/MKRPGUNITT.
The first test

The most basic test case would be one customer with one order. So we write our first test. Change SUMBYCUSTT to the following.

    H NoMain                                                    
                                                                
                                                                
     //---------------------------------------------------------
     //  Files                                                  
     //---------------------------------------------------------
                                                                
    FCUSTSUMS  IF   E             DISK    UsrOpn                
    FORDERS    O    E             DISK    UsrOpn                
                                                                
                                                                
     //---------------------------------------------------------
     //  Prototypes                                             
     //---------------------------------------------------------
                                                                
     /copy RPGUNIT1,TESTCASE                                    
                                                                
     // Program under test.                                     
    D SumByCust       pr                  ExtPgm('SUMBYCUST')   
                                                                
     // Test case prototypes.                                   
    Dtest_one_customer_one_order...                             
    D                 pr
                                                                
     //---------------------------------------------------------
     //  Test Case Definitions                                  
     //---------------------------------------------------------
                                                                
    Ptest_one_customer_one_order...                             
    P                 b                   Export                
    Dtest_one_customer_one_order...                             
    D                 pi                                        
     /free                                                      
                                                                
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
         assert( not %eof : 'File CUSTSUMS should not be empty' );
         aEqual( 'A001' : CUSTID );                              
         iEqual( 1000 : SUM );                                   
       close CUSTSUMS;                                           
                                                                 
     /end-free                                                   
    P                 e                                          

    We compile this test suite.

    ===> RUCRTTST TSTPGM(SUMBYCUSTT) SRCFILE(RUTUTORIAL)

    We run this test suite.

    ===> RUCALLTST SUMBYCUSTT
    ERROR. 1 test case, 0 assertion, 0 failure, 1 error.

    Looking at the job log we can see what is the problem.

    Cannot resolve to object SUMBYCUST.

    The problem can also be found by looking at the RPGUNIT spool file (User Data SUMBYCUSTT).

    *** Tests from SUMBYCUSTT ***                                                   
    TEST_ONE_CUSTOMER_ONE_ORDER - ERROR                                             
    MCH3401 - Cannot resolve to object SUMBYCUST. Type and Subtype X'0201' Authority
     X'0000'.                                                                       
    -----------------------                                                         
    ERROR. 1 test case, 0 assertion, 0 failure, 1 error.

The problem is that we have not created the SUMBYCUST program yet. Let's create an RPGLE source member called SUMBYCUST with the following content.

     //---------------------------------------------------------
     //  Main Procedure                                         
     //---------------------------------------------------------

     /free         
                   
       *inlr = *on;
                   
     /end-free     

You may feel underwhelmed by this implementation. Yet it is the simplest thing that will remove the error and allow to proceed on.
Compile this program stub.

    ===> CRTBNDRPG PGM(SUMBYCUST) SRCFILE(RUTUTORIAL)

    We run the test suite again.

    ===> RUCALLTST SUMBYCUSTT
    FAILURE. 1 test case, 1 assertion, 1 failure, 0 error.

    Better! No technical error and one assertion failure.
    Looking at the latest RPGUNIT spool file, we can find some details about the failure.

    *** Tests from SUMBYCUSTT ***                             
    TEST_ONE_CUSTOMER_ONE_ORDER - FAILURE                     
    File CUSTSUMS should not be empty                         
      assert (RUTESTCASE:8500)                                
      TEST_ONE_CUSTOMER_ONE_ORDER (SUMBYCUSTT:5600)           
    -----------------------                                   
    FAILURE. 1 test case, 1 assertion, 1 failure, 0 error.

    Our test case is complaining that the output file of SUMBYCUST, the CUSTSUMS file, is empty.
    Let's improve our SUMBYCUST program a little bit. The new code is highlighted.

     //---------------------------------------------------------
     //  Files                                                  
     //---------------------------------------------------------
                                                                
    FCUSTSUMS  O    E             DISK                          
                                                                
                                                                
     //---------------------------------------------------------
     //  Main Procedure                                         
     //---------------------------------------------------------
                                                                
     /free                                                      
                                                                
       write CUSTSUM;                                           
                                                                
       *inlr = *on;                                             
                                                                
     /end-free                                                  

This is a fake implementation. Although it is obvious this cannot be the final implementation, it should be enough to fix the failure.
Compiling this new version of SUMBYCUST and running the tests suite once more, we get the following message.

    ===> CRTBNDRPG PGM(SUMBYCUST) SRCFILE(RUTUTORIAL)
    ===> RUCALLTST SUMBYCUSTT
    FAILURE. 1 test case, 2 assertions, 1 failure, 0 error.

Has nothing changed? Maybe not. Let's check the failure report (DSPSPLF FILE(RPGUNIT) SPLNBR(*LAST)).

    *** Tests from SUMBYCUSTT ***                             
    TEST_ONE_CUSTOMER_ONE_ORDER - FAILURE                     
    Expected 'A001', but was ''.                              
      assert (RUTESTCASE:8500)                                
      aEqual (RUTESTCASE:6600)                                
      TEST_ONE_CUSTOMER_ONE_ORDER (SUMBYCUSTT:5700)           
    -----------------------                                   
    FAILURE. 1 test case, 2 assertions, 1 failure, 0 error.

The failure is different. Now, the test case finds the record it expects, but the content is wrong. Looking up line 57.00 of source member SUMBYCUSTT, we can see that the field CUSTID is wrong. It is blank, though it should contain the customer ID "A001".
Let's fix the program under test so that both the customer ID and the order amount sum are correct. Again, it will be only a fake implementation.

     //---------------------------------------------------------
     //  Main Procedure                                         
     //---------------------------------------------------------
                                                                
     /free                                                      
                                                                
       CUSTID = 'A001';                                         
       SUM = 1000;                                              
       write CUSTSUM;                                           
                                                                
       *inlr = *on;                                             
                                                                
     /end-free                                                  

    After compiling the program and running the test, we get the following message.

    Success. 1 test case, 3 assertions, 0 failure, 0 error.

Victory! Our first test case runs successfully, albeit using a fake implementation.
There is some code duplication between the program under test and the test program. Let's refactor the magic values ("A001" and 1000) that we find in both programs, by really reading the ORDERS file this time.

     //---------------------------------------------------------
     //  Files                                                  
     //---------------------------------------------------------
                                                                
    FORDERS    IF   E             DISK                          
    FCUSTSUMS  O    E             DISK                          
                                                                
                                                                
     //---------------------------------------------------------
     //  Main Procedure                                         
     //---------------------------------------------------------
                                                                
     /free                                                      
                                                                
       read ORDER;                                              
       SUM = ORDERAMT;                                          
       write CUSTSUM;                                           
                                                                
       *inlr = *on;                                             
                                                                
     /end-free                                                  

We compile the refactored program and run the test. Since it is still successful, we can be sure our refactoring did not break anything that used to work. The astute reader will have noticed there is still some code duplication in the test program, but we will leave it there, because seeing the same hardcoded values in the setup part and in the check part can be nice when reading a test case.

Summing orders from the same customer

Let's add a test case with two orders from the same customer. This will force us to write the summing logic.

     // Test case prototypes.                   
    Dtest_one_customer_one_order...             
    D                 pr                        
    Dtest_one_customer_two_orders...            
    D                 pr                        

    ...

    Ptest_one_customer_two_orders...            
    P                 b                   Export
    Dtest_one_customer_two_orders...            
    D                 pi                        
     /free                                      
                                                
       // Setup.                                
                                                
       clrpfm('ORDERS');                        
       clrpfm('CUSTSUMS');                      
                                                
       open ORDERS;                             
         ORDERID = 1;                           
         CUSTID = 'A001';                       
         ORDERAMT = 1000;                       
         write ORDER;                           
         
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
         assert( not %eof : 'File CUSTSUMS should not be empty' );
         aEqual( 'A001' : CUSTID );                              
         iEqual( 1000+2000 : SUM );                              
       close CUSTSUMS;                                           
                                                                 
     /end-free                                                   
    P                 e                                          

    We compile and run the enhanced test program.

    ===> RUCRTTST TSTPGM(SUMBYCUSTT) SRCFILE(RUTUTORIAL)
    ===> RUCALLTST SUMBYCUSTT
    FAILURE. 2 test cases, 6 assertions, 1 failure, 0 error.

    The latest RPGUNIT spool file contains the following information.

    *** Tests from SUMBYCUSTT ***                           
    TEST_ONE_CUSTOMER_TWO_ORDERS - FAILURE                  
    Expected 3000, but was 1000.                            
      assert (RUTESTCASE:8500)                              
      iEqual (RUTESTCASE:25600)                             
      TEST_ONE_CUSTOMER_TWO_ORDERS (SUMBYCUSTT:10000)       
    -----------------------                                 
    FAILURE. 2 test cases, 6 assertions, 1 failure, 0 error.

It looks like RPGUnit has found out that our summing programming is not summing anything at all.
We add a simple looping logic in the SUMBYCUST program.

       read ORDER;                    
                                      
       dow not %eof;                  
         SUM += ORDERAMT;             
         read ORDER;                  
       enddo;                         
                                      
       write CUSTSUM;                 

Compiling the improved program and running the tests, we get a success.

    ===> CRTBNDRPG PGM(SUMBYCUST) SRCFILE(RUTUTORIAL)
    ===> RUCALLTST SUMBYCUSTT
    Success. 2 test cases, 6 assertions, 0 failure, 0 error.

Although the program under test is clean (i.e., no duplication), the same cannot be said of the test program. There is some duplication between the two tests. We will now use the special procedure setUp to put the shared code. The RPGUnit framework will call this procedure once before running each test procedure. Let's factor the duplicated code of SUMBYCUSTT.

     // Test case prototypes.            
    DsetUp            pr                 
    Dtest_one_customer_one_order...      
    D                 pr                 
    Dtest_one_customer_two_orders...     
    D                 pr


     //---------------------------------------------------------
     //  Test Case Definitions                                  
     //---------------------------------------------------------
                                                                
    PsetUp            b                   Export                
    DsetUp            pi                                        
     /free                                                      
                                                                
       clrpfm('ORDERS');                                        
       clrpfm('CUSTSUMS');                                      
                                                                
       open ORDERS;                                             
         ORDERID = 1;                                           
         CUSTID = 'A001';                                       
         ORDERAMT = 1000;                                       
         write ORDER;                                           
       close ORDERS;                                            
                                                                
     /end-free                                                  
    P                 e                                         
                                                                
                                                                
    Ptest_one_customer_one_order...                             
    P                 b                   Export                
    Dtest_one_customer_one_order...                              
    D                 pi                                         
     /free                                                       
                                                                 
       // Setup.                                                 
                                                                 
       // Run.                                                   
                                                                 
       SumByCust();                                              
                                                                 
       // Check.                                                 
                                                                 
       open CUSTSUMS;                                            
         read CUSTSUM;                                           
         assert( not %eof : 'File CUSTSUMS should not be empty' );
         aEqual( 'A001' : CUSTID );                              
         iEqual( 1000 : SUM );                                   
       close CUSTSUMS;                                           
                                                                 
     /end-free                                                   
    P                 e                                          
                                                                 
                                                                 
    Ptest_one_customer_two_orders...                             
    P                 b                   Export                   
    Dtest_one_customer_two_orders...                               
    D                 pi                                           
     /free                                                         
                                                                   
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
          assert( not %eof : 'File CUSTSUMS should not be empty' );
          aEqual( 'A001' : CUSTID );                               
          iEqual( 1000+2000 : SUM );
        close CUSTSUMS;             
                                    
     /end-free                      
    P                 e             

After refactoring the test code, we run the test again, to make sure we did not break anything. The test program is still successful.

Not summing orders from different customers

Let's add a new test case. This time, there will be two customers, with one order each.

     // Test case prototypes.            
    DsetUp            pr                 
    Dtest_one_customer_one_order...      
    D                 pr                 
    Dtest_one_customer_two_orders...     
    D                 pr                 
    Dtest_two_customers_one_order_each...
    D                 pr                 

    ...

    Ptest_two_customers_one_order_each...       
    P                 b                   Export
    Dtest_two_customers_one_order_each...       
    D                 pi                        
     /free                                      
                                                
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
         assert( not %eof : 'File CUSTSUMS should not be empty' );    
         aEqual( 'A001' : CUSTID );                                  
         iEqual( 1000 : SUM );                                       
                                                                     
         // Second customer.                                         
         read CUSTSUM;                                               
         assert( not %eof : 'File CUSTSUMS should have two records' );
         aEqual( 'B002' : CUSTID );                                  
         iEqual( 2000 : SUM );                                       
       close CUSTSUMS;                                               
                                                                     
     /end-free                                                       
    P                 e                                              

    This new test fails.

    TEST_TWO_CUSTOMERS_ONE_ORDER_EACH - FAILURE
    Expected 'A001', but was 'B002'.           

The problem is that the program under test does not handle the customer identifier at all.
Let's improve the program under test (i.e., SUMBYCUST) so that it handles customer breaks.


     //---------------------------------------------------------  
     //  Global Variables                                         
     //---------------------------------------------------------  
                                                                  
      // Current order.                                           
    D orderDS         ds                  LikeRec(ORDER)          
      // Current customer sum.                                    
    D custSumDS       ds                  LikeRec(CUSTSUM:*output)
      // Customer break indicator.                                
    D custBreak       s               n                           
                                                                  
                                                                  
     //---------------------------------------------------------  
     //  Main Procedure                                           
     //---------------------------------------------------------  
                                                                  
     /free                                                        
                                                                  
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
                                                          
     /end-free                                            

Compiling the program under test and running the test program, we get a success.

Handling customers in any order

There is still a weakness in the program. Customers may not always be grouped together in the order file. We should check how the program handles that. Let's add a test in SUMBYCUSTTT.


    Ptest_two_customers_with_orders_not_grouped...
    P                 b                   Export  
    Dtest_two_customers_with_orders_not_grouped...
    D                 pi                          
     /free                                        
                                                  
       // Setup.                                  
                                                  
       open ORDERS;                               
         ORDERID = 2;                             
         CUSTID = 'B002';                         
         ORDERAMT = 2000;                         
         write ORDER;                             
                                                  
         ORDERID = 3;                             
         CUSTID = 'A001';  // Back to the first customer.
         ORDERAMT = 3000;                         
         write ORDER;                             
       close ORDERS;                              
                                                  
       // Run.                                    
                                                  
       SumByCust();                               
                                                  
       // Check.                                                 
                                                                 
       open CUSTSUMS;                                            
         read CUSTSUM;                                           
         assert( not %eof : 'File CUSTSUMS should not be empty' );
         aEqual( 'A001' : CUSTID );                              
         iEqual( 1000+3000 : SUM );                              
                                                                 
         // No test on second customer.                          
       close CUSTSUMS;                                           
                                                                 
     /end-free                                                       
    P                 e                                              

As could be expected, this test fails.

    TEST_TWO_CUSTOMERS_WITH_ORDERS_NOT_GROUPED - FAILURE
    Expected 4000, but was 1000.                        

There are several ways to deal with the customer ordering. Here, we'll use a logical file. Let's call it ORDERS2.

                    R ORDER                     PFILE(ORDERS)
                                                             
                    K CUSTID                                 
                    K ORDERID                                

We change SUMBYCUST so that it uses ORDERS2 instead of ORDERS.

     //---------------------------------------------------------
     //  Files                                                  
     //---------------------------------------------------------
                                                                
    FORDERS2   IF   E           K DISK                          
    FCUSTSUMS  O    E             DISK                          

    The tests are successful.

Source code

For your convenience, here is the full source for the test program and the program under test.

    H NoMain                                                    
                                                            
                                                            
     //---------------------------------------------------------
     //  Files                                                  
     //---------------------------------------------------------
                                                            
    FCUSTSUMS  IF   E             DISK    UsrOpn                
    FORDERS    O    E             DISK    UsrOpn                
                                                            
                                                            
     //---------------------------------------------------------
     //  Prototypes                                             
     //---------------------------------------------------------
                                                            
     /copy RPGUNIT1,TESTCASE                                    
                                                            
     // Program under test.                                     
    D SumByCust       pr                  ExtPgm('SUMBYCUST')   
                                                            
     // Test case prototypes.                                   
    DsetUp            pr                                        
    Dtest_one_customer_one_order...                             
    D                 pr                                        
    Dtest_one_customer_two_orders...                            
    D                 pr                                        
    Dtest_two_customers_one_order_each...                       
    D                 pr                                        
    Dtest_two_customers_with_orders_not_grouped...              
    D                 pr                                        
                                                            
                                                            
     //---------------------------------------------------------
     //  Test Case Definitions                                  
     //---------------------------------------------------------
                                                            
    PsetUp            b                   Export                
    DsetUp            pi                                        
     /free                                                      
                                                            
       clrpfm('ORDERS');                                        
       clrpfm('CUSTSUMS');                                      
                                                            
       open ORDERS;                                             
         ORDERID = 1;                                           
         CUSTID = 'A001';                                       
         ORDERAMT = 1000;                                       
         write ORDER;                                           
       close ORDERS;                                             
                                                             
     /end-free                                                   
    P                 e                                          
                                                             
                                                             
    Ptest_one_customer_one_order...                              
    P                 b                   Export                 
    Dtest_one_customer_one_order...                              
    D                 pi                                         
     /free                                                       
                                                             
       // Setup.                                                 
                                                             
       // Run.                                                   
                                                             
       SumByCust();                                              
                                                             
       // Check.                                                 
                                                             
       open CUSTSUMS;                                            
         read CUSTSUM;                                           
         assert( not %eof : 'File CUSTSUMS should not be empty' );
         aEqual( 'A001' : CUSTID );                              
         iEqual( 1000 : SUM );                  
       close CUSTSUMS;                          
                                            
     /end-free                                  
    P                 e                         
                                            
                                            
    Ptest_one_customer_two_orders...            
    P                 b                   Export
    Dtest_one_customer_two_orders...            
    D                 pi                        
     /free                                      
                                            
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
         assert( not %eof : 'File CUSTSUMS should not be empty' );
         aEqual( 'A001' : CUSTID );                              
         iEqual( 1000+2000 : SUM );                              
       close CUSTSUMS;                                           
                                                             
     /end-free                                                   
    P                 e                                          
                                                             
                                                             
    Ptest_two_customers_one_order_each...                        
    P                 b                   Export                 
    Dtest_two_customers_one_order_each...                        
    D                 pi                                         
     /free                                                       
                                                             
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
         assert( not %eof : 'File CUSTSUMS should not be empty' );    
         aEqual( 'A001' : CUSTID );                                  
         iEqual( 1000 : SUM );                                       
                                                                 
         // Second customer.                                         
         read CUSTSUM;                                               
         assert( not %eof : 'File CUSTSUMS should have two records' );
         aEqual( 'B002' : CUSTID );                                  
         iEqual( 2000 : SUM );                                       
       close CUSTSUMS;                            
                                              
     /end-free                                    
    P                 e                           
                                              
                                              
    Ptest_two_customers_with_orders_not_grouped...
    P                 b                   Export  
    Dtest_two_customers_with_orders_not_grouped...
    D                 pi                          
     /free                                        
                                              
       // Setup.                                  
                                              
       open ORDERS;                               
         ORDERID = 2;                             
         CUSTID = 'B002';                         
         ORDERAMT = 2000;                         
         write ORDER;                             
                                              
         ORDERID = 3;                             
         CUSTID = 'A001';                         
         ORDERAMT = 3000;                         
         write ORDER;                             
       close ORDERS;                                             
                                                             
       // Run.                                                   
                                                             
       SumByCust();                                              
                                                             
       // Check.                                                 
                                                             
       open CUSTSUMS;                                            
         read CUSTSUM;                                           
         assert( not %eof : 'File CUSTSUMS should not be empty' );
         aEqual( 'A001' : CUSTID );                              
         iEqual( 1000+3000 : SUM );                              
                                                             
         // No test on second customer.                          
       close CUSTSUMS;                                           
                                                             
     /end-free                                                   
    P                 e                                          

     //---------------------------------------------------------  
     //  Files                                                    
     //---------------------------------------------------------  
                                                              
    FORDERS2   IF   E           K DISK                            
    FCUSTSUMS  O    E             DISK                            
                                                              
                                                              
     //---------------------------------------------------------  
     //  Global Variables                                         
     //---------------------------------------------------------  
                                                              
      // Current order.                                           
    D orderDS         ds                  LikeRec(ORDER)          
      // Current customer sum.                                    
    D custSumDS       ds                  LikeRec(CUSTSUM:*output)
      // Customer break indicator.                                
    D custBreak       s               n                           
                                                              
                                                              
     //---------------------------------------------------------  
     //  Main Procedure                                           
     //---------------------------------------------------------  
                                                              
     /free                                                
                                                      
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
                                                      
     /end-free                                            

Source code in fixed position

If you are not comfortable with free format, here is the equivalent in fixed-position style.

    H NoMain


     //---------------------------------------------------------
     //  Files
     //---------------------------------------------------------
    FCUSTSUMS  IF   E             DISK    UsrOpn
     FORDERS    O    E             DISK    UsrOpn


     //---------------------------------------------------------
     //  Prototypes
     //---------------------------------------------------------

     /copy RPGUNIT1,TESTCASE

     // Program under test.
    D SumByCust       pr                  ExtPgm('SUMBYCUST')

     // Test case prototypes.
    DsetUp            pr
    Dtest_one_customer_one_order...
    D                 pr
    Dtest_one_customer_two_orders...
    D                 pr
    Dtest_two_customers_one_order_each...
    D                 pr
    Dtest_two_customers_with_orders_not_grouped...
    D                 pr


     //---------------------------------------------------------
     //  Test Case Definitions
     //---------------------------------------------------------

    PsetUp            b                   Export
    DsetUp            pi
    C                   callp     clrpfm('ORDERS')
    C                   callp     clrpfm('CUSTSUMS')

    C                   open      ORDERS
    C                   eval      ORDERID = 1
    C                   eval      CUSTID = 'A001'
    C                   eval      ORDERAMT = 1000
    C                   write     ORDER
    C                   close     ORDERS
    P                 e


    Ptest_one_customer_one_order...
    P                 b                   Export
    Dtest_one_customer_one_order...
    D                 pi

     // Setup.

     // Run.
    C                   callp     SumByCust()

     // Check.
    C                   open      CUSTSUMS
    C                   read      CUSTSUM
    C                   callp     assert( not %eof
    C                                   : 'File CUSTSUMS should not be empty' )
    C                   callp     aEqual( 'A001' : CUSTID )
    C                   callp     iEqual( 1000 : SUM )
    C                   close     CUSTSUMS
    P                 e


    Ptest_one_customer_two_orders...
    P                 b                   Export
    Dtest_one_customer_two_orders...
    D                 pi

     // Setup.
    C                   open      ORDERS
    C                   eval      ORDERID = 2
    C                   eval      CUSTID = 'A001'
    C                   eval      ORDERAMT = 2000
    C                   write     ORDER
    C                   close     ORDERS

     // Run.
    C                   callp     SumByCust()

     // Check.
    C                   open      CUSTSUMS
    C                   read      CUSTSUM
    C                   callp     assert( not %eof
    C                                   : 'File CUSTSUMS should not be empty' )
    C                   callp     aEqual( 'A001' : CUSTID )
    C                   callp     iEqual( 1000+2000 : SUM )
    C                   close     CUSTSUMS

    P                 e


    Ptest_two_customers_one_order_each...
    P                 b                   Export
    Dtest_two_customers_one_order_each...
    D                 pi

     // Setup.
    C                   open      ORDERS
    C                   eval      ORDERID = 2
    C                   eval      CUSTID = 'B002'
    C                   eval      ORDERAMT = 2000
    C                   write     ORDER
    C                   close     ORDERS

     // Run.
    C                   callp     SumByCust()

     // Check.
    C                   open      CUSTSUMS
     // First customer.
    C                   read      CUSTSUM
    C                   callp     assert( not %eof
    C                                   : 'File CUSTSUMS should not be empty' )
    C                   callp     aEqual( 'A001' : CUSTID )
    C                   callp     iEqual( 1000 : SUM )

     // Second customer.
    C                   read      CUSTSUM
    C                   callp     assert( not %eof
    C                               : 'File CUSTSUMS should have two records' )
    C                   callp     aEqual( 'B002' : CUSTID )
    C                   callp     iEqual( 2000 : SUM )
    C                   close     CUSTSUMS
    P                 e


    Ptest_two_customers_with_orders_not_grouped...
    P                 b                   Export
    Dtest_two_customers_with_orders_not_grouped...
    D                 pi

     // Setup.
    C                   open      ORDERS
    C                   eval      ORDERID = 2
    C                   eval      CUSTID = 'B002'
    C                   eval      ORDERAMT = 2000
    C                   write     ORDER

    C                   eval      ORDERID = 3
    C                   eval      CUSTID = 'A001'                              Back to 1st customer
    C                   eval      ORDERAMT = 3000
    C                   write     ORDER
    C                   close     ORDERS

     // Run.
    C                   callp     SumByCust()

     // Check.
    C                   open      CUSTSUMS
    C                   read      CUSTSUM
    C                   callp     assert( not %eof
    C                                   : 'File CUSTSUMS should not be empty' )
    C                   callp     aEqual( 'A001' : CUSTID )
    C                   callp     iEqual( 1000+3000 : SUM )

     // No test on second customer.
    C                   close     CUSTSUMS
    P                 e                                    

     //---------------------------------------------------------
     //  Files
     //---------------------------------------------------------

    FORDERS2   IF   E           K DISK
    FCUSTSUMS  O    E             DISK


     //---------------------------------------------------------
     //  Global Variables
     //---------------------------------------------------------

      // Current order.
    D orderDS         ds                  LikeRec(ORDER)
          // Current customer sum.
    D custSumDS       ds                  LikeRec(CUSTSUM:*output)


     //---------------------------------------------------------
     //  Main Procedure
     //---------------------------------------------------------

    C                   READ      ORDER         orderDS
    C                   CLEAR                   custSumDS
    C                   EVAL      custSumDS.CUSTID = orderDS.CUSTID

    C                   DOW       not %eof

    C                   IF        custSumDS.CUSTID <> orderDS.CUSTID           Customer break
    C                   WRITE     CUSTSUM       custSumDS
    C                   CLEAR                   custSumDS
    C                   EVAL      custSumDS.CUSTID = orderDS.CUSTID
    C                   ENDIF

    C                   EVAL      custSumDS.SUM += orderDS.ORDERAMT
    C                   READ      ORDER         orderDS
    C                   ENDDO

    C                   WRITE     CUSTSUM       custSumDS

    C                   SETON                                        LR

