create or replace PROCEDURE   proc_getjson (C1 OUT SYS_REFCURSOR,P_ACCOUNT_NO IN VARCHAR2)
IS

    h_res      CLOB; --VARCHAR2 (4000);
  /*  *********************************************     */
    REQ        UTL_HTTP.REQ;
    RES        UTL_HTTP.RESP;
    URL        VARCHAR2 (4000);
    BUFFER     VARCHAR2 (4000);
    CONTENT    VARCHAR2 (4000); 
  /*  *********************************************     */
  
    v_accountBranch                 VARCHAR2(100);
    v_accountCategoryCode           VARCHAR2(100);
    v_accountCategoryDescription    VARCHAR2(100);
    v_accountCurrency               VARCHAR2(100);
    v_accountName                   VARCHAR2(100);
    v_accountNo                     VARCHAR2(100);
    v_accountOpeningDate            VARCHAR2(100);
    v_clientId                      VARCHAR2(100);
    v_clientIndicator               VARCHAR2(100);
    v_depositType                   VARCHAR2(100);
    v_intAccrFromDate               VARCHAR2(100);
    v_lastChangeDate                VARCHAR2(100);
    v_lastCreditDateBnk             VARCHAR2(100);
    v_lastCreditDateCus             VARCHAR2(100);
    v_lastDebitDateCus              VARCHAR2(100);
    v_nextIntCycleDate              VARCHAR2(100);
    v_odFacility                    VARCHAR2(100);   	
    v_odFacilityAmount              VARCHAR2(100);
    v_onlineActualBalance           VARCHAR2(100);
    v_onlineClearedBalance          VARCHAR2(100);
    v_openActualBalance             VARCHAR2(100);
    v_openClearedBalance            VARCHAR2(100);
    v_ownershipType                 VARCHAR2(100);
    v_restraintsPresent             VARCHAR2(100);
    v_totalPledgedAmount            VARCHAR2(100);
    v_workingBalance                VARCHAR2(100);
    
BEGIN

 DECLARE
 
 /* ****  get JSON body from URL *** */
 
    BEGIN
       
        URL :='http://10.18.50.145:7800/esb/account/Accountinfo?accountNo='|| P_ACCOUNT_NO; -- URL from ESB
        
        DBMS_OUTPUT.PUT_LINE (URL);
        REQ := UTL_HTTP.BEGIN_REQUEST (URL, 'GET', ' HTTP/1.1');
        UTL_HTTP.SET_HEADER (REQ, 'user-agent', 'mozilla/4.0');

        UTL_HTTP.SET_HEADER (REQ, 'content-type', 'application/json');
        UTL_HTTP.SET_HEADER (REQ, 'Content-Length', LENGTH (CONTENT));
        UTL_HTTP.WRITE_TEXT (REQ, CONTENT);
        RES := UTL_HTTP.GET_RESPONSE (REQ);

        BEGIN
            LOOP
                  UTL_HTTP.READ_LINE (RES, BUFFER);
                  DBMS_OUTPUT.PUT_LINE (BUFFER);   
                
                  h_res:=BUFFER;
                        
            END LOOP;
                  UTL_HTTP.END_RESPONSE (RES);
        EXCEPTION
            WHEN  UTL_HTTP.END_OF_BODY
            THEN
                  UTL_HTTP.END_RESPONSE (RES);
        END;
        
/* ****  JSON result convert to tabular format *** */
    BEGIN
     OPEN C1 FOR        

    select res.* into   v_accountBranch, v_accountCategoryCode,v_accountCategoryDescription,v_accountCurrency,
                        v_accountName,v_accountNo,v_accountOpeningDate,v_clientId,v_clientIndicator,v_depositType,
                        v_intAccrFromDate,v_lastChangeDate,v_lastCreditDateBnk,v_lastCreditDateCus,v_lastDebitDateCus,
                        v_nextIntCycleDate,v_odFacility,v_odFacilityAmount,v_onlineActualBalance,v_onlineClearedBalance,
                        v_openActualBalance,v_openClearedBalance,v_ownershipType,v_restraintsPresent,v_totalPledgedAmount,
                        v_workingBalance
    FROM(
        with json as 
( select (h_res) doc  
  from   dual  
)  
SELECT     
    ACCOUNTBRANCH,ACCOUNTCATEGORYCODE,ACCOUNTCATEGORYDESCRIPTION,ACCOUNTCURRENCY,    	
    ACCOUNTNAME,ACCOUNTNO,ACCOUNTOPENINGDATE,CLIENTID,CLIENTINDICATOR,DEPOSITTYPE,
    INTACCRFROMDATE,LASTCHANGEDATE,LASTCREDITDATEBNK,LASTCREDITDATECUS,LASTDEBITDATECUS,
    NEXTINTCYCLEDATE,ODFACILITY,ODFACILITYAMOUNT,ONLINEACTUALBALANCE,ONLINECLEAREDBALANCE,
    OPENACTUALBALANCE,OPENCLEAREDBALANCE,OWNERSHIPTYPE,RESTRAINTSPRESENT,TOTALPLEDGEDAMOUNT,WORKINGBALANCE 
	 
FROM  json_table( (select doc from json) , '$[*]'  
                COLUMNS (   ACCOUNTBRANCH               PATH '$.accountBranch', 
                            ACCOUNTCATEGORYCODE         PATH '$.accountCategoryCode',
                            ACCOUNTCATEGORYDESCRIPTION  PATH '$.accountCategoryDescription',
                            ACCOUNTCURRENCY 			      PATH '$.accountCurrency',
                            ACCOUNTNAME 				        PATH '$.accountName',
                            ACCOUNTNO 					        PATH '$.accountNo',
                            ACCOUNTOPENINGDATE 			    PATH '$.accountOpeningDate',
                            CLIENTID 					          PATH '$.clientId',
                            CLIENTINDICATOR 			      PATH '$.clientIndicator',
                            DEPOSITTYPE 				        PATH '$.depositType',
                            INTACCRFROMDATE 			      PATH '$.intAccrFromDate',
                            LASTCHANGEDATE 				      PATH '$.lastChangeDate',
                            LASTCREDITDATEBNK 			    PATH '$.lastCreditDateBnk',
                            LASTCREDITDATECUS 			    PATH '$.lastCreditDateCus',
                            LASTDEBITDATECUS 			      PATH '$.lastDebitDateCus',
                            NEXTINTCYCLEDATE 			      PATH '$.nextIntCycleDate',
                            ODFACILITY 					        PATH '$.odFacility',   	
                            ODFACILITYAMOUNT 			      PATH '$.odFacilityAmount',
                            ONLINEACTUALBALANCE 		    PATH '$.onlineActualBalance',
                            ONLINECLEAREDBALANCE 		    PATH '$.onlineClearedBalance', 
                            OPENACTUALBALANCE 			    PATH '$.openActualBalance',
                            OPENCLEAREDBALANCE 			    PATH '$.openClearedBalance',
                            OWNERSHIPTYPE 				      PATH '$.ownershipType',
                            RESTRAINTSPRESENT 			    PATH '$.restraintsPresent',
                            TOTALPLEDGEDAMOUNT 			    PATH '$.totalPledgedAmount',
                            WORKINGBALANCE 				      PATH '$.workingBalance'
                              
                        )  
               ))res;
              -- close C1;
               
     EXCEPTION
             WHEN NO_DATA_FOUND THEN
                    NULL;
            WHEN OTHERS THEN
                    -- Consider logging the error and then re-raise
                    RAISE;
      END;
      
        END;
    END;