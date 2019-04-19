/**
* @description Utility class for PEGA interface
* 
* @author
*
* @change HCL 08/15/2016 Added getPlanBenefitIDs to get all Benefit Package IDs for given set of Products
*/

public without sharing class P2EhUtility {   
    
    public static boolean hasContractTriggerToBeExecuted = true;
    //-- Added the logic for Heat:1740298
    //Modified By: Parthiban P, Modified on 18-03-2016
    public static void putContractTriggerToBeExecuted(){
        hasContractTriggerToBeExecuted = false;
    }  
    //-- Ending code for Heat:1740298  
    //PC-14058
    public static boolean hasOpptyDeleteTriggerExecuted = true;
    public static void putOpptyDeleteTriggerExecuted (){
        hasOpptyDeleteTriggerExecuted = false;
    }
    //End of PC-14058      
    public static String reframeJson(String jsonStr, List<String> objApiList){
        system.debug(jsonStr + 'Line 4');
        //List<String> objApiList = new List<String> { 'Product2', 'CostShare__c', 'TTPLs__c' };
        for(String objApi : objApiList){
            Set<String> removeFields = new Set<String>{'url','Id','IsDeleted','CreatedById', 
                'LastModifiedDate','LastModifiedById','SystemModStamp',
                'LastActivityDate','LastViewedDate','LastReferencedDate','OwnerId','CreatedDate'};
                    Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objApi).newSObject().getSObjectType().getDescribe().fields.getMap();
            for(String fldName : fieldMap.keyset()){
                if(fieldMap.get(fldName).getDescribe().isCalculated() 
                   || fieldMap.get(fldName).getDescribe().isExternalId()){
                       removeFields.add(fieldMap.get(fldName).getDescribe().getName());
                   }
            }
            //system.debug('removeFields ::' +removeFields);
            //String toSearch = '{"attributes":{"type":"' + ObjApi + '","url":"/services/data/' + System.Label.APIVersion + '/sobjects/' + objApi;
            String toSearch = '{"attributes":{"type":"' + ObjApi + '","url":"/services/data/';
            system.debug( 'Json_util' +jsonStr );
            while(jsonStr.contains(toSearch)){
                String splitStr = jsonStr.mid(jsonStr.indexOf(toSearch), toSearch.length()+22+15+ObjApi.length());
                if(ObjApi.contains('Product2') && jsonStr.contains('UWQuestionnaire__c')){
                    //jsonStr = jsonStr.replaceAll('\"','');
                    String a = jsonStr.substringAfter('"UWQuestionnaire__c":"').split('}"', 2)[0];
                    String b = '"UWQuestionnaire__c":"';
                    if(jsonStr.contains(b+a+'}"}')){
                        jsonStr = jsonStr.remove(b+a+'}"');
                    }else{
                        jsonStr = jsonStr.remove(b+a+'}",');
                    }
                }
                String srcStr = splitStr + jsonStr.substringAfter(splitStr).split('}', 2)[0] + '}';
                //system.debug('splitStr :: ' + splitStr);
                //system.debug('srcStr :: ' + srcStr);
                if(jsonStr.indexOf(toSearch) != -1){
                    for(String remField : removeFields){
                        String toRemove = '"'+ remField +'":"';
                        if(srcStr.contains(toRemove)){
                            //system.debug('remField :: '+ remField);
                            //system.debug('toRemove :: '+ toRemove);
                            //system.debug('srcStr 0 :: '+ srcStr.substringAfter(toRemove).split('"')[0]);
                            //system.debug('srcStr 1 :: '+ srcStr.substringAfter(toRemove).split('"')[1]);
                            if(srcStr.substringAfter(toRemove).split('"')[1].startsWith(',')){
                                jsonStr = jsonStr.remove(toRemove + srcStr.substringAfter(toRemove).split('"')[0] + '",');
                            }else{
                                jsonStr = jsonStr.remove(',' + toRemove + srcStr.substringAfter(toRemove).split('"')[0] + '"');
                            }
                        }
                    }
                }
            }
        }
        return jsonStr;
    }
    public static boolean hasOpptyUpdateWithAM = true;
    public static void putOpptyAMStatus(){
        hasOpptyUpdateWithAM = false;
    }  
    //Page Navigation
    public static integer indexOf(List<String> strList, string selectedPlan){
        Integer i = 0;
        for(string SPlan : strList){
            if(Splan == selectedPlan){
                return i;
            }
        } 
        return i++; 
    }
    
    //Record Type
    public static String getRecordTypeName(Id recId, Id recTypeId){
        return recId.getSobjectType().getDescribe().getRecordTypeInfosById().get(recTypeId).getName();
    }
    
    public static Id getRecordTypeId(String sObjName, String recordTypeName){
        return Schema.getGlobalDescribe().get(sObjName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }
    Public static Map<Id,String> getRecordTypeIDNameMap(String objectAPIName){
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objectAPIName).getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Map<Id,String>  mapofRecordTypeIdandName = new Map<Id,String> ();
        for(Schema.RecordTypeInfo info : recordTypeInfo){
            mapofRecordTypeIdandName.put(info.getRecordTypeId(),info.getName());
        }
        Return mapofRecordTypeIdandName;
    }
    
    public static sObject setBooleanDefault(String obj, sObject sobj){
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(obj).newSObject().getSObjectType().getDescribe().fields.getMap();
        for(String fldName : fieldMap.keyset()){
            if(!fieldMap.get(fldName).getDescribe().isCalculated() && !fieldMap.get(fldName).getDescribe().isExternalId()){
                if(fieldMap.get(fldName).getDescribe().getType() == Schema.DisplayType.BOOLEAN && fldName!='IsDeleted' && fldName!='IsArchived'){
                    if(sobj.get(fldName) == null){
                        sobj.put(fldName, false);
                    }
                }
            }
        }
        return sobj;
    }
    
    // SOQL
    public static String getQuery(String obj){
        Set<String> fieldSet = Schema.getGlobalDescribe().get(obj).newSObject().getSObjectType().getDescribe().fields.getMap().keyset();
        Set<String> removeFields = new Set<String>{'isdeleted','createdbyid','lastmodifieddate','lastmodifiedbyid','systemmodstamp','sourceid','lastactivitydate','lastvieweddate','lastreferenceddate'};
            Boolean result = fieldSet.removeAll(removeFields);
        String query = 'SELECT ';
        for(String fieldName : fieldSet){
            if(fieldName == 'NAICLookup__c'){
                query = query + 'NAICLookup__r.NAIC__c,NAICLookup__r.NAIC_Industry__c,';
            }         
            query = query + fieldName + ', ';
        }
        if(obj =='Opportunity'){     
            query = query + 'Account.Name,Account.BillingCity,Account.BillingCountry,Account.BillingCountryCode,Account.BillingPostalCode,Account.BillingState,Account.BillingStateCode,Account.BillingStreet,Account.ShippingCity,Account.ShippingCountry,Account.ShippingCountryCode,Account.ShippingPostalCode,Account.ShippingState,Account.ShippingStateCode,Account.ShippingStreet';
        }
        if(obj =='Case'){     
            query = query + 'Recordtype.Name';
        }
        if(obj =='Rates__c'){     
            query = query + 'Span__r.Billing_Span_End_Date__c,Span__r.Billing_Span_Start_Date__c';
        }
        query = query.removeEnd(', ');
        query += ' FROM ' + obj + ' ';
        return query;
    }
    
    // Integration Log
    public static void integLog(String srvName, boolean isCallout, string req, String res, String statusCode, Id logId){
        Integration_Log__c intLog = new Integration_Log__c();
        intLog.Service_Name__c = srvName;
        intLog.Date_Time__c = System.Now();
        intLog.Log__c = logId;
        System.debug('Request******----->'+req);
        if(req!=null){
            if(req.length()<=131000){
                intLog.Request1__c = req;
            }else if(req.length()>131000 && req.length()<=262000){
                intLog.Request1__c = req.subString(0,131000);
                intLog.Request2__c = req.subString(131001);
            }else if(req.length()>262000 && req.length()<=393000){
                intLog.Request1__c = req.subString(0,131000);
                intLog.Request2__c = req.subString(131001, 262000);
                intLog.Request3__c = req.subString(262001);
            }else if(req.length()>393000 && req.length()<=524000){
                intLog.Request1__c = req.subString(0,131000);
                intLog.Request2__c = req.subString(131001, 262000);
                intLog.Request3__c = req.subString(262001, 393000);
                intLog.Request4__c = req.subString(393001);
                //intLog.Request1__c = req;
            }else if(req.length()>524000 && req.length()<=655000){
                intLog.Request1__c = req.subString(0,131000);
                intLog.Request2__c = req.subString(131001, 262000);
                intLog.Request3__c = req.subString(262001, 393000);
                intLog.Request4__c = req.subString(393001, 524000);
                intLog.Request5__c = req.subString(524001);
            }else{
                intLog.Request1__c = req.subString(0,131000);
                intLog.Request2__c = req.subString(131001, 262000);
                intLog.Request3__c = req.subString(262001, 393000);
                intLog.Request4__c = req.subString(393001, 524000);
                intLog.Request5__c = req.subString(524001,655000);
                intLog.Request6__c = req.subString(655001);
            }
        }
        if(res!=null){
            system.debug('Response*****------->'+res);
            system.debug('@@@1'+res.length());
            if(res.length()<=131000){
                intLog.Response1__c = res;
            }else if(res.length()>131000 && res.length()<=262000){
                intLog.Response1__c = res.subString(0,131000);
                intLog.Response2__c = res.subString(131001);
            }else if(res.length()>262000 && res.length()<=393000){
                intLog.Response1__c = res.subString(0,131000);
                intLog.Response2__c = res.subString(131001, 262000);
                intLog.Response3__c = res.subString(262001);
            }else if(res.length()>393000 && res.length()<=524000){
                system.debug('@@@2'+res.length());
                intLog.Response1__c = res.subString(0,131000);
                intLog.Response2__c = res.subString(131001, 262000);
                intLog.Response3__c = res.subString(262001, 393000);
                intLog.Response4__c = res.subString(393001);
                //intLog.Request1__c = req;
            }else if(res.length()>524000 && res.length()<=655000){
                intLog.Response1__c = res.subString(0,131000);
                intLog.Response2__c = res.subString(131001, 262000);
                intLog.Response3__c = res.subString(262001, 393000);
                intLog.Response4__c = res.subString(393001, 524000);
                intLog.Response5__c = res.subString(524001);
            }else{
                intLog.Response1__c = res.subString(0,131000);
                intLog.Response2__c = res.subString(131001, 262000);
                intLog.Response3__c = res.subString(262001, 393000);
                intLog.Response4__c = res.subString(393001, 524000);
                intLog.Response5__c = res.subString(524001,655000);
                intLog.Response6__c = res.subString(655001);
            }
        }
        intLog.Http_Status_Code__c = statusCode;
        try{
            if(srvName != 'SF009'){  
                insert intLog;
            }  
        }catch(Exception e){
            system.debug('insert Log Failed ::: ' + intLog);
        }
    }
    
    public static Map<Id, Set<Id>> cloneProducts(Map<Id, Integer> prdIdMulClnMap){
        
        try{
            
            
            Set<Id> prodIds = prdIdMulClnMap.keyset();
            List<WPDCache__c> oldWPDList = Database.Query(P2EhUtility.getQuery('WPDCache__c') + ' Where Product__c in: prodIds Order By PartNumber__c ASC');
            Map<Id, String> oldPlanStrMap = new Map<Id, String>();
            for(WPDCache__c wpd : oldWPDList){
                String jsonStr = oldPlanStrMap.get(wpd.Product__c);
                if(jsonStr!=null){
                    jsonStr += wpd.WPDJSON__c;
                }else{
                    jsonStr = wpd.WPDJSON__c;
                }
                oldPlanStrMap.put(wpd.Product__c, jsonStr);
            }
            
            Integer c = 1;
            List<P2EwWizPlanDesign> wizPDList = new List<P2EwWizPlanDesign>();
            for(Id prodId : oldPlanStrMap.keyset()){
                String jsonStr = P2EhUtility.reframeJson(oldPlanStrMap.get(prodId), new List<String> { 'Product2', 'CostShare__c', 'TTPLs__c', 'RateSheet__c', 'Rates__c' });
                for(integer i=0; i<prdIdMulClnMap.get(prodId); i++){
                    P2EwWizPlanDesign wizPD = (P2EwWizPlanDesign) System.JSON.deserialize(jsonStr, P2EwWizPlanDesign.class);
                    wizPD.product.PlanID__c = String.valueOf(c);
                    wizPD.product.oldId__c = prodId;
                    wizPDList.add(wizPD);
                    c++;
                }
            }
            P2EhDML dml = new P2EhDML();
            dml.toDMLlist = new List<SObject>();
            if(wizPDList!=null && !wizPDList.isEmpty()){
                for(P2EwWizPlanDesign wPD : wizPDList){
                    dml.toDMLlist.add(wPD.product);
                }
            }
            dml.action = P2EenDML.Insertion;
            dml.doDML();
            
            Map<Id, Set<Id>> origMulClndProdMap = new Map<Id, Set<Id>>();
            Set<Id> clndProdIds;
            for(P2EwWizPlanDesign wPD :wizPDList){
                if(origMulClndProdMap.get(wpd.product.oldId__c)!=null){
                    clndProdIds = origMulClndProdMap.get(wpd.product.oldId__c);
                }else{
                    clndProdIds = new Set<Id>();
                }
                clndProdIds.add(wpd.product.Id);
                origMulClndProdMap.put(wpd.product.oldId__c, clndProdIds);
            }
            
            List<SObject> csLst = new List<SObject>();
            List<SObject> rsLst = new List<SObject>();
            if(wizPDList!=null && !wizPDList.isEmpty()){
                for(P2EwWizPlanDesign wPD : wizPDList){ //cache.clonedProducts)
                    for(P2EwWizCostShare wCS : wPD.costShareList){
                        wCS.costShare.Plan_Design__c = wPD.product.Id;
                        csLst.add(wCS.costShare);
                    }
                    /*for(P2EwWizRateSheets wRS : wPD.rateSheetList){
if(wRS.rateSheet.Type__c!='Request'){
wRS.rateSheet.Product2__c = wPD.product.Id;
rsLst.add(wRS.rateSheet);
}
}
if(wPD.prodSegments!=null && !wPD.prodSegments.isEmpty()){
for(P2EwWizProductSegment wPS : wPD.prodSegments){
wPS.segment.Product2__c = wPD.product.Id;
dml.toDMLlist.add(wRS.rateSheet);
}
}*/           
                }
            }
            
            dml.toDMLlist.clear();
            dml.toDMLlist.addAll(csLst);
            dml.toDMLlist.addAll(rsLst);
            dml.action = P2EenDML.Insertion;
            dml.doDML();
            
            List<SObject> ttLst = new List<SObject>();
            List<SObject> orLst = new List<SObject>();
            List<SObject> arLst = new List<SObject>();
            //List<SObject> psLst = new List<SObject>();
            if(wizPDList!=null && !wizPDList.isEmpty()){
                for(P2EwWizPlanDesign wPD : wizPDList){ //cache.clonedProducts)
                    for(P2EwWizCostShare wCS : wPD.costShareList){
                        for(TTPLs__c ttPL : wCS.treatmentTypes){
                            ttPL.CostShare__c = wCS.costShare.Id;
                            ttLst.add(ttPL);
                        }
                    }
                    /*for(P2EwWizRateSheets wRS : wPD.rateSheetList){
if(wRS.rateSheet.Type__c!='Request'){
if(wRS.originalRates!=null){
for(Rates__c rates: wRS.originalRates){
rates.RateSheet__c= wRS.rateSheet.Id;
orLst.add(rates);
}
}
if(wRS.adminRates!=null){
for(Rates__c rates: wRS.adminRates){
rates.RateSheet__c= wRS.rateSheet.Id;
arLst.add(rates);
}
}
}
/*
if(wRS.prodSegments!=null){
for(ProdSegment__c prodSegm : wRS.prodSegments){
prodSegm.RateSheet__c = wRS.rateSheet.Id;
psLst.add(prodSegm);
}
}

}
*/
                }
            }
            dml.toDMLlist.clear();
            dml.toDMLlist.addAll(orLst);
            dml.toDMLlist.addAll(arLst);
            //dml.toDMLlist.addAll(psLst);
            dml.action = P2EenDML.Insertion;
            dml.doDML();
            
            dml.toDMLlist.clear();
            dml.toDMLlist.addAll(ttLst);
            dml.action = P2EenDML.Insertion;
            dml.doDML();
            
            return origMulClndProdMap;
            
        }
        
        catch(P2EException e){
            e.addSource('P2EhUtility - cloneProducts()');
            e.logException();
        } 
        return null;  
        
    }
    
    public Static void withdrawfunc(Set<Id> qtids){ 
        List<Quote> quoteList = [Select Id, Name,AutoQuote__c, originalcaseid__c, QuoteNumber,Status,OpportunityId, RFP_Case_Id__c,RFP_Case_Status__c  FROM quote where Id in:qtids];     //Modified for PC-12024
        set<Id> oppids = new set<Id>();
        //Added for PC-12024
        Set<String> rfpIds = new Set<String>();
        Map<String,Set<String>> mapParImplSubCases = new Map<String,Set<String>>();//13581 by geetha on nov 4
        for(Quote q:quoteList){         
            oppids.add(q.OpportunityId);
            if(q.RFP_Case_Id__c != Null || q.originalcaseid__c != Null){
                if(q.RFP_Case_Id__c != Null){
                    rfpIds.add(q.RFP_Case_Id__c);
                }
                if(q.originalcaseid__c != Null){
                    rfpIds.add(q.originalcaseid__c);
                }
            }
        }
        //Upto this for PC-12024          
        Opportunity opp = [select id,name,AccountId,RecordTypeID,type,StageName,Renewal_Opportunity__c from opportunity where id in:oppids Limit 1]; // Modified for PC-12024
        /*if(opp.type!='New'){
Case oldcase = [Select Id,Status,Quote__c,RFP_Case_Id__c  FROM Case WHERE Related_Opportunity__c =:opp.Id AND Subject LIKE '%RFP%' AND Status!='Withdrawn' Limit 1];
if(oldcase!=null){
oldcase.Status = 'Withdrawn';                   
update oldcase;
}
}*/
        Id RecId = [Select Id, Name from RecordType where name = 'RFP'].Id;  
        if(opp.type=='New' || opp.type=='Renewal' || opp.type=='Change'){      
            List<Case> lstCase = new List<Case>();
            //Added for PC-12024
            Set<String> implIds = new Set<String>();
            List<OpportunityLineItem> updOli = new List<OpportunityLineItem>();
            if(opp.type=='New'){
                for(OpportunityLineItem oli: [Select Id, RFP_Case_Id__c, Parent_Impl_Case_Id__c, Parent_Impl_Case_Status__c,Impl_Case_Id__c from OpportunityLineItem Where RFP_Case_Id__c IN: rfpIds]){
                    if(oli.Parent_Impl_Case_Id__c != Null){
                        implIds.add(oli.Parent_Impl_Case_Id__c);
                    }
                    //oli.Parent_Impl_Case_Status__c = 'Resolved-Withdrawn';
                    updOli.add(oli);              
                }
            }
            if(opp.type=='Renewal' || opp.type=='Change'){
                for(OpportunityLineItem oli: [Select Id, RFP_Case_Id__c, Parent_Impl_Case_Id__c,Impl_Case_Id__c, Parent_Impl_Case_Status__c from OpportunityLineItem Where opportunityid =: opp.id]){
                    if(oli.Parent_Impl_Case_Id__c != Null){
                        implIds.add(oli.Parent_Impl_Case_Id__c);
                    }                  
                    updOli.add(oli);              
                }
            }
            //13581
            if(updOli.size() > 0){
                for(OpportunityLineItem oliForChatter:updOli){
                    if(oliForChatter.Impl_Case_Id__c!=null){
                        if(mapParImplSubCases.isEmpty() || mapParImplSubCases.get(oliForChatter.Parent_Impl_Case_Id__c).size()==0){
                            mapParImplSubCases.put(oliForChatter.Parent_Impl_Case_Id__c,new Set<String>());
                        }
                        mapParImplSubCases.get(oliForChatter.Parent_Impl_Case_Id__c).add(oliForChatter.Impl_Case_Id__c);
                    }
                }
                //update updOli;
                delete updOli;
            }
            //till here for 13581
            List<FeedItem> insertLstFeedItem  = new List<FeedItem>();     
            for(Case c: [Select Id,Type,UW_Case_ID__c, Status from Case Where UW_Case_ID__c IN: rfpIds OR UW_Case_ID__c IN: implIds]){
                c.Status = 'Withdrawn';
                lstCase.add(c);
                //13581
                FeedItem fitem;                                 
                fitem = new FeedItem();
                fitem.ParentId = c.Id;
                if(c.Type=='RFP'){
                    fitem.body = 'A withdraw request has been initiated by the user on Proposal Case '+c.UW_Case_ID__c+'. Please take necessary steps to backout the changes from downstream systems.';
                }
                if(c.Type=='Implementation'){
                    fitem.body = 'A withdraw request has been initiated by the user on Implementation Case '+c.UW_Case_ID__c+'. Please take necessary steps to backout the changes from downstream systems.';
                }
                fitem.type = 'TextPost';
                //fitem.LinkUrl = '/'+c.Id;
                fitem.Title = 'Open Case';                                                     
                insertLstFeedItem.add(fitem); 
                List<String> subCaseLst = new List<String>();              
                if(c.Type=='Implementation' && !mapParImplSubCases.isEmpty() && mapParImplSubCases.get(c.UW_Case_ID__c).size()>0){
                    for(String subcase:mapParImplSubCases.get(c.UW_Case_ID__c)){
                        subCaseLst.add(subcase);
                    }    
                    String fnlList = String.join(subCaseLst, ',');
                    FeedItem fitem1;                                 
                    fitem1 = new FeedItem();
                    fitem1.ParentId = c.Id;
                    fitem1.body = 'A withdraw request has been initiated by the user on the Implementation Case Parent '+c.UW_Case_ID__c+' and sub cases '+fnlList +'. Please take necessary steps to backout the changes from downstream systems.';
                    fitem1.type = 'TextPost';
                    //fitem1.LinkUrl = '/'+c.Id;
                    fitem1.Title = 'Open Case';                                                     
                    insertLstFeedItem.add(fitem1);    
                }           
            }
            if(insertLstFeedItem.size()>0){
                system.debug('Feed Item:'+ insertLstFeedItem);
                insert insertLstFeedItem;
            }
            //till here for 13581
            
            if(lstCase.size() > 0){
                update lstCase;
            }
            //Upto this for PC-12024
            system.debug('into if condition');
            for(Quote qt:quoteList){
                qt.Status = 'Withdrawn';
                qt.AutoQuote__c = false;
            }
            update quoteList;
            
            system.debug('quoteList'+quoteList);
            if(opp.type == 'New'){
                //opp.StageName = 'Prospecting';  // Changed for Sales Stage - Sujit 
                opp.StageName = Label.Sales_Stages_Prospecting;
                opp.Workflow_Stage__c = Label.Sales_Stages_Prospecting;             
                update opp;           
            }
            if(opp.type == 'Change'){
                // Changed for Sales Stage - Sujit
                //opp.StageName = 'Closed Withdrawn';
                opp.StageName = Label.Sales_Stages_Closed_Withdrawn;
                opp.Workflow_Stage__c = Label.Sales_Stages_Closed_Withdrawn;
                opp.RecordTypeID = P2EhUtility.getRecordTypeId('Opportunity', 'Change Withdrawn');
                opp.Probability = 0;
                opp.ForecastCategoryName = 'Omitted';                
                update opp;          
            }
            if(opp.type=='Renewal'){              
                Integer count = [select count() from Quote where OpportunityId=:opp.Id];                 
                Quote dummyquote = new Quote();
                dummyquote.Name = 'Q' + opp.Name + count;
                dummyquote.OpportunityId=opp.Id;
                dummyquote.AutoQuote__c = true;
                insert dummyquote;
                
                //opp.StageName = 'Retention Activity';
                opp.StageName = Label.Sales_Stages_Retention_Activity; // Changed for Sales Stage - Sujit 
                opp.Workflow_Stage__c = Label.Sales_Stages_Retention_Activity;
                opp.RecordTypeID = P2EhUtility.getRecordTypeId('Opportunity', 'Renewal Opportunity');
                update opp;
                
                Case dummycase = new case();
                dummycase.Opportunity__c = opp.Id;                  
                dummycase.RecordTypeId = RecId;
                dummycase.AccountId = opp.AccountId;
                dummycase.Related_Opportunity__c = opp.Id; 
                dummycase.Reason = 'Request For Proposal';
                dummycase.Type = 'RFP';
                dummycase.Subject = 'RFP Case :::';
                insert dummycase;
            }
        }
        if(opp.type=='Change'){
            for(Quote qt:quoteList){         
                qt.Status = 'Withdrawn';
            }
            update quoteList;
            case cs = [select id,Status from case where ChangeOpportunity__c=:opp.Id and Related_Opportunity__c=:opp.Renewal_Opportunity__c Limit 1];
            cs.status='Withdrawn';
            if(cs!=null){
                update cs; 
            }       
        }
        if(opp.Type != 'New'){
            List<RateSheet__c> rsListToDelete = [select id,Type__c,Response_Quote__c,Request_Quote__c from RateSheet__c where Response_Quote__c in:qtids OR (Type__c='New' AND Request_Quote__c in:qtids)];                 
            system.debug('rsListToDelete'+rsListToDelete);
            if(rsListToDelete.size()>0){
                delete rsListToDelete ;
            } 
            Map<Id,List<RateSheet__c>> ReqQuoteRatesheetMap = new Map<Id,List<RateSheet__c>>();
            Map<Id,List<RateSheet__c>> ResQuoteRatesheetMap = new Map<Id,List<RateSheet__c>>();          
            String qidsToBeRemoved;
            for(Id qid: qtids){
                qidsToBeRemoved = String.valueOf(qid);
                break;
            }
            String LikeTag = '%'+qidsToBeRemoved+'%';
            List<RateSheet__c> rsList = [select id,Type__c,Request_Quote__c,Response_Quote__c,isSentToImplementation__c,isCurrentRatesheet__c from RateSheet__c Where Request_Quote__c LIKE: LikeTag OR Response_Quote__c LIKE: LikeTag];//GC Re-Rate
            List<RateSheet__c> rsListToUpdate1 = new List<RateSheet__c>();
            List<RateSheet__c> rsListToUpdate2 = new List<RateSheet__c>();
            for(Quote qt:quoteList){
                for(RateSheet__c rs:rsList){
                    if(rs.Request_Quote__c!=null && rs.Request_Quote__c.contains(String.valueof(qt.id))){
                        if(ReqQuoteRatesheetMap.get(qt.Id)==null){
                            ReqQuoteRatesheetMap.put(qt.Id,new List<RateSheet__c>());
                        }
                        ReqQuoteRatesheetMap.get(qt.Id).add(rs);
                    }
                    if(rs.Response_Quote__c!=null && rs.Response_Quote__c.contains(String.valueof(qt.id))){
                        if(ResQuoteRatesheetMap.get(qt.Id)==null){
                            ResQuoteRatesheetMap.put(qt.Id,new List<RateSheet__c>());
                        }
                        ResQuoteRatesheetMap.get(qt.Id).add(rs);
                    }
                }
                String rqid = String.valueof(qt.id); 
                if(!ReqQuoteRatesheetMap.isEmpty() && ReqQuoteRatesheetMap.get(qt.Id).size()>0){
                    for(RateSheet__c rs:ReqQuoteRatesheetMap.get(qt.Id)){                                                                 
                        if((rs.Type__c=='InActivate' && ((rs.Request_Quote__c==rqid && rs.Response_Quote__c==null) || (rs.Response_Quote__c!=null && rs.Request_Quote__c!=rs.Response_Quote__c)))){                            
                            rs.Type__c='Activate';
                            if(rs.isCurrentRatesheet__c==false && rs.isSentToImplementation__c==true){//GC Re-Rate Start
                                rs.isCurrentRatesheet__c=true;
                            }//GC Re-Rate Start
                        }
                        rs.Request_Quote__c = rs.Request_Quote__c.remove(qt.id);
                        rsListToUpdate1.add(rs);
                    }
                }
                if(!ResQuoteRatesheetMap.isEmpty() && ResQuoteRatesheetMap.get(qt.Id).size()>0){
                    for(RateSheet__c rs:ResQuoteRatesheetMap.get(qt.Id)){                       
                        rs.Response_Quote__c = rs.Response_Quote__c.remove(qt.id);                       
                        rsListToUpdate2.add(rs);
                    }
                }        
            }
            if(rsListToUpdate1.size()>0){
                update rsListToUpdate1;
            }
            if(rsListToUpdate2.size()>0){
                update rsListToUpdate2;
            }
        }                
    }
    
    /**
* @description Method to get Benefit Package Ids as a comma separated list for all the products
* 
* @param prodIds Ids of all products in question
* 
* @return Map of Products to Benefit Package Ids
*/
    public static Map<String,String> getPlanBenefitIDs(Set<Id>  prodIds){
        
        //Get all the junction object records for all prodIds
        List<ProdBenefit__c> prodBenefits = new List<ProdBenefit__c>([Select ID, Product__c, Product__r.PlanID__c, Benefit_Package_ID__c from 
                                                                      ProdBenefit__c where Product__c in: prodIds]);
        
        Map<String,String> planToBenefitMap = new Map<String,String>();
        
        //Prepare a map of all Products in question to comma separated Benefit Package Ids
        if(!prodBenefits.isEmpty()){
            for(ProdBenefit__c prodBen : prodBenefits){
                if(prodBen.Product__c!= null && String.isNotBlank(prodBen.Product__r.PlanID__c) && String.isNotBlank(prodBen.Benefit_Package_ID__c)){
                    if(planToBenefitMap.containsKey(prodBen.Product__r.PlanID__c)){
                        planToBenefitMap.put(prodBen.Product__r.PlanID__c, planToBenefitMap.get(prodBen.Product__r.PlanID__c) + ',' + prodBen.Benefit_Package_ID__c);
                    }else{
                        planToBenefitMap.put(prodBen.Product__r.PlanID__c,prodBen.Benefit_Package_ID__c);
                    }
                }
            }
        }
        
        return planToBenefitMap;
    }
    public static case divideJSON(string serializedJSONObj, Case c) {
        /*if(math.mod(serializedJSONObj.length(),250)==0){
        integer totalBlocks = (serializedJSONObj.length())/250;
        integer startIndex = 0;
        integer endIndex = 250;
        for(integer i=0;i<totalBlocks;i++) {
        string JSONVal = serializedJSONObj.substring(startIndex, endIndex);
        string fieldName = 'GroupDivisionJSON_'+i+'__c';
        c.put(fieldName, JSONVal);
        startIndex = endIndex;
        endIndex = startIndex+250;
        }
        }
        else{*/
                /*c.GroupDivisionJSON_0__c=null;
        c.GroupDivisionJSON_1__c=null;
        c.GroupDivisionJSON_2__c=null;
        c.GroupDivisionJSON_3__c=null;*/
        for(integer i=0;i<=3;i++){
            string fieldName = 'GroupDivisionJSON_'+i+'__c';
            c.put(fieldName, null);
        }
        integer maxlength = 131072; //Max limit allowed is 131072
        integer totalBlocks = (serializedJSONObj.length())/maxlength;
        integer startIndex = 0;
        integer endIndex = maxlength;
        for(integer i=0;i<totalBlocks+1;i++) {                                                                
            if(serializedJSONObj.length() <= endIndex) {
                endIndex =serializedJSONObj.length();
            }
            string JSONVal = serializedJSONObj.substring(startIndex, endIndex);
            string fieldName = 'GroupDivisionJSON_'+i+'__c';
            c.put(fieldName, JSONVal);
            startIndex = endIndex;
            endIndex = startIndex+maxlength;
        }
        //}    
        return c;
    }
    public static String mergeJSON(Case c) {
        String finalStr='';
        for(Integer i=0;i<=3;i++){
            string fieldName = 'GroupDivisionJSON_'+i+'__c';
            System.debug('fieldName merge VP - '+ fieldName); 
            if(c.get(fieldName)!=null){
                finalStr=finalStr+c.get(fieldName);
            }    
        }
         System.debug('finalStr merge VP - '+ finalStr); 
        return finalStr;    
    }   
    /**
* @description To divide related list json data
* @param {serializedJSONObj} Json string 
* @param {gih} object     
*/
    public static SObject divideGroupJSON(String serializedJSONObj, SObject gih, Boolean isCase) {  
        System.debug('isCase'+ isCase);  
        String fieldName = isCase ? 'GroupDivisionJSON_*__c' : 'JsonStringGroupHist_*__c';
        Integer maxlength = 131072; //Max limit allowed is 131072
        Integer totalBlocks = (serializedJSONObj.length())/maxlength;     
        Integer startIndex = 0;
        Integer endIndex = maxlength;
        Integer noOfFields = 9;//isCase ? 9 : 9;
        
        for(Integer i=0; i<=noOfFields; i++){
            //fieldName = fieldName.replace('*', i+'');
            String fieldName1 = fieldName.replace('*', i+'');
            gih.put(fieldName1, null);
        }
        
        if(serializedJSONObj.length()<= 131072 ) {
            startIndex = 0;
            endIndex = serializedJSONObj.length();
            
            String JSONVal = serializedJSONObj.substring(startIndex, endIndex);
            
            fieldName = fieldName.replace('*', '0');
            gih.put(fieldName, JSONVal);           
        } else {
            for(Integer i=0;i<noOfFields;i++) {                                                                
                if(serializedJSONObj.length() <= endIndex) {
                    endIndex =serializedJSONObj.length();
                }
                
                String JSONVal = serializedJSONObj.substring(startIndex, endIndex);
                
                //fieldName = fieldName.replace('*', i+'');
                String fieldName1 = fieldName.replace('*', i+'');
                gih.put(fieldName1, JSONVal);
                startIndex = endIndex;
                endIndex = startIndex+maxlength;                                  
            }   
        } 
         System.debug('gih :'+ gih);
        return gih;
    }
    
    /**
* @description To merge related list json data
* @param {grphist} respective Object
* @param 
*/
    public static String mergeGroupHistroyJSON(Group_Info_History__c grphist) {
        String finalStr='';
        for(Integer i=0;i<=4;i++){
            string fieldName = 'JsonStringGroupHist_'+i+'__c';         
            if(grphist.get(fieldName)!=null){
                finalStr=finalStr+grphist.get(fieldName);
            }             
        }   
        return finalStr;    
    }
    
    /* Method to fetch fields details form fieldset
    * @param - fieldSetName
    * @param - ObjectName
    */
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName) {
        system.debug('fieldSetName VP - '+fieldSetName);
         system.debug('ObjectName VP - '+ObjectName);
        Map<String, Schema.SObjectType> GlobalDescribeMap; 
        Schema.SObjectType SObjectTypeObj;
        Schema.DescribeSObjectResult DescribeSObjectResultObj;
        Schema.FieldSet fieldSetObj;        
        try {
            GlobalDescribeMap = Schema.getGlobalDescribe(); 
            SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
            system.debug('SObjectTypeObj VP - '+SObjectTypeObj);
            DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
            fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
             System.debug('fieldSetObj: '+fieldSetObj);
        } catch(Exception e) {
            System.debug('readFieldSet: '+e.getMessage()+' line '+e.getLineNumber());
        }
        
        return fieldSetObj.getFields(); 
    }
}