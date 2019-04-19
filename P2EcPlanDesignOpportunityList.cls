/**
 * @description Controller for Sold Plan Designs Implementation section on Opportunity Page
 * 
 * @author P2E Team
 *
 * @change Jaleel  10/12/2017 Added logic for Rich Text Area fields
 *
 */

public class P2EcPlanDesignOpportunityList{    
    public list<task> taskList{ get; set; }
    public List<OpportunityLineItem> displstOLI { get; set; }
    public List<OpportunityLineItem> sendlstOLI { get; set; }
    public List<OpportunityLineItem> reimplOLI { get; set; }
    public List<OpportunityLineItem> implOLI { get; set; }
    public List<OpportunityLineItem> decPendOLI;//added for PC-14067
    public String OppId{ get; set; }
    public Boolean showButton{ get; set; }
    public Boolean showButton1{ get; set; }
    public Boolean isRerate{ get; set; }
    //public case implCase { get; set; }
    public Id selectedAccountId;
    public case caseinsert;
    public Set<Id> selProdIds;
    public List<Quote> quoteList { get; set; }
    public set<string> RFPid { get; set; }
    public boolean hide { get; set; }
    public Opportunity opp { get; set; }
    //public Note note{get;set;}
    public Integer i = 0;
    public Boolean a = false;
    Public Opportunity OpptyNRC;//14067
    public Map<Id,List<OpportunityLineItem>> mapQuoteOli= new Map<Id,List<OpportunityLineItem>>();//added for PC-14067
    //by Geetha for PC-13439 on nov 3      
    public String salesNotes { get; set; }                          
    public Implementation_Notes__c noteInfo{ get; set; }                    
    public List<Implementation_Notes__c> noteToDisplay{get;set;}                
    public List<Implementation_Notes__c> noteToDisplayAll{get;set;}         
    Public String ImplChoosed {get;set;}        
    public boolean displayPopup {get; set;}         
    public integer totalRecsForCase{get;set;}           
    public integer totalRecsForOppty{get;set;}      
    public integer OffsetSize{get;set;}                 
    public integer LimitSize{get;set;}          
    public integer OffsetSizeAll{get;set;}          
    public integer LimitSizeAll{get;set;} 
    public String selProdId{get;set;}//Geetha PC-15498
    public set<id> prdIdSet;//Geetha PC-15498 
    public Map<Id,List<String>> mapPrdBenId{get;set;}//Geetha PC-15498
    public Boolean displayPopupNew { get; set; }// Geetha PC-15498
    public List<ProdBenefit__c> prdBenLst{get;set;}//Geetha PC-15498
    public Boolean RenderColumn{get;set;}//Geetha PC-15498
    public Quote qt{get;set;}//QA WF
    public Id selectedProdId{
        get;
        set{
            selectedProdId= value;            
        }
    }  
    //till here for 13439
    //@Jaleel - 10122017 - Rich Text Area requirement
    private Id implNoteRecordTypeId;
    
    public P2EcPlanDesignOpportunityList(ApexPages.StandardController controller) {
        OppId = ApexPages.currentPage().getParameters().get('id');
        init();
    }
    
    public P2EcPlanDesignOpportunityList(Id oppId) {
        this.OppId = oppId;
        init();
    }
    
    private void init(){
        displstOLI = new List<OpportunityLineItem>();
        sendlstOLI = new List<OpportunityLineItem>();
        RenderColumn=false;
        prdIdSet = new Set<Id>();//Geetha PC-15498
        displayPopupNew = false;   // Geetha PC-15498
        mapPrdBenId = new Map<Id,List<String>>(); // Geetha PC-15498
        taskList =new list<task>();
        selProdIds = new Set<Id>();
        quoteList = new List<Quote>();
        //note = new Note();
        RFPid = new set<string>();
        showButton=true;
        showButton1=true;
        opp = new Opportunity();
        hide = true;
        isRerate = false;
        OpptyNRC = Database.Query(P2EhUtility.getQuery('Opportunity') + ' Where Id = \'' + OppId + '\' Limit 1');//14067
        //13439
        noteInfo = new Implementation_Notes__c();
        noteToDisplay = new List<Implementation_Notes__c>();
        noteToDisplayAll = new List<Implementation_Notes__c>();//By Geetha for query optimisation
        /****@Jaleel - 10122017 - RichTextArea Requirement****/
        implNoteRecordTypeId = Schema.SObjectType.Implementation_Notes__c.getRecordTypeInfosByName().get('Implementation').getRecordTypeId();

        //noteToDisplay = [select id,createdById,createdDate,CreatedBy.name,Implementation_Notes__c,Parent_Impl_Case_Id__c,Title__c from Implementation_Notes__c where Parent_Impl_Case_Id__c =:ImplChoosed and RecordTypeId=:implNoteRecordTypeId order by createdDate desc Limit 3];//commented by geetha for query optimisation
        //noteToDisplayAll = [select id,createdById,createdDate,Opportunity__c,CreatedBy.name,Implementation_Notes__c,Parent_Impl_Case_Id__c,Title__c from Implementation_Notes__c where Opportunity__c=:OppId and RecordTypeId=:implNoteRecordTypeId order by createdDate desc Limit 3];//commented by geetha for query optimisation
        
        OffsetSizeAll=0;
        LimitSizeAll=3;
        noteToDisplayAll = notesLstAll(OffsetSizeAll); //added by Geetha for query optimisation
        totalRecsForOppty = [select count() from Implementation_Notes__c where Opportunity__c=:OppId and RecordTypeId=:implNoteRecordTypeId];
        //till here for 13439
        
        reimplOLI = [SELECT Product2.PlanID__c,Product2.GroupPlanName__c,Opportunity.type,Product2.Sold__c,Quote__c,IsRateUpdated__c,IsRerate__c,Opportunity.AccountId, Product2Id, QQ_Case_Id__c, RFP_Case_Id__c, 
                                         Group_Number__c, id, Impl_Case_Id__c, Impl_Case_Status__c,Par_Impl_case_Id_Hide__c, Par_Impl_case_status_Hide__c, Parent_Impl_Case_Id__c,
                        Parent_Impl_Case_Status__c, Product2.Name, Decision_Status__c, Action__c 
                        FROM OpportunityLineItem WHERE OpportunityId =: OppId AND IsRerate__c = TRUE AND Par_Impl_case_Id_Hide__c <> null AND RFP_Case_Id__c <> null AND ((Parent_Impl_Case_Id__c <> null AND Decision_Status__c <> 'Decision Pending' and Action__c IN ('Discontinue')) OR (Decision_Status__c = 'Sold'))];
        
        implOLI = [SELECT Product2.PlanID__c,Product2.GroupPlanName__c,Opportunity.type,Product2.Sold__c,Quote__c,IsRateUpdated__c,IsRerate__c,Opportunity.AccountId, Product2Id, QQ_Case_Id__c, RFP_Case_Id__c, 
                                         Group_Number__c, id, Impl_Case_Id__c, Impl_Case_Status__c,Par_Impl_case_Id_Hide__c, Par_Impl_case_status_Hide__c, Parent_Impl_Case_Id__c,
                        Parent_Impl_Case_Status__c, Product2.Name, Decision_Status__c, Action__c 
                        FROM OpportunityLineItem WHERE OpportunityId =: OppId 
                        AND ((Action__c IN ('New', 'Update', 'Existing') AND Decision_Status__c = 'Sold') 
                        OR (Action__c IN ('Discontinue') AND Decision_Status__c IN ('Not - Sold')) ) AND IsRerate__c = FALSE];
        decPendOLI = [SELECT Product2.PlanID__c,Product2.GroupPlanName__c,Opportunity.type,Product2.Sold__c,IsRateUpdated__c,Quote__c,IsRerate__c,Opportunity.AccountId, Product2Id, QQ_Case_Id__c, RFP_Case_Id__c, 
                                         Group_Number__c, id, Impl_Case_Id__c, Impl_Case_Status__c,Par_Impl_case_Id_Hide__c, Par_Impl_case_status_Hide__c, Parent_Impl_Case_Id__c,
                        Parent_Impl_Case_Status__c, Product2.Name, Decision_Status__c, Action__c 
                        FROM OpportunityLineItem WHERE OpportunityId =: OppId AND Decision_Status__c ='Decision Pending' AND Quote__r.Status!='Withdrawn' AND Quote__r.RFP_Case_Id__c!=null AND Quote__r.RFP_Case_Status__c='Resolved-Completed'];//14067
        if(decPendOLI .size()>0){                
        for(OpportunityLineItem oli:decPendOLI){
                if(mapQuoteOli.get(oli.Quote__c)==null){
                    mapQuoteOli.put(oli.Quote__c,new List<OpportunityLineItem>());
                }
                mapQuoteOli.get(oli.Quote__c).add(oli);
            }
        }//till here for 14067
        system.debug('Line 52'+implOLI );
        
        if(implOLI!=null && implOLI.isEmpty()==false){
            displstOLI.addAll(implOLI);
            for(OpportunityLineItem oli : implOLI){
                system.debug('Line 65'+oli.Parent_Impl_Case_Id__c);
                if(oli.Parent_Impl_Case_Id__c == null && oli.Parent_Impl_Case_Status__c != 'Resolved-Withdrawn'){
                    showButton = false;
                }
            }
        }
        if(reimplOLI!=null && reimplOLI.isEmpty()==false){
            displstOLI.addAll(reimplOLI);
            showButton1 = false;
        }
        system.debug('Line 76'+displstOLI);
        set<String> RFPIdSet=new set<String>();//QA WF
        /*** Geetha PC-15498 start***/
        for(OpportunityLineItem oliFin:displstOLI){
            prdIdSet.add(oliFin.Product2Id);
            if(oliFin.RFP_Case_Id__c!=null){
                RFPIdSet.add(oliFin.RFP_Case_Id__c);
            }    
        }
        if(RFPIdSet.size()>0){
            qt=[select id,Sales_Notes__c,UW_Notes__c,RFP_Case_Id__c,Is_Rerated_Quote__c from Quote where RFP_Case_Id__c IN:RFPIdSet Limit 1];
        }
        List<ProdBenefit__c> prdBenLst = [select id,Benefit_Package__c,Benefit_Package_ID__c,Product__c,Benefit_Package__r.Benefit_Package_ID__c,Product__r.Id from ProdBenefit__c where Product__r.Id in: prdIdSet];
        Map<Id,List<String>> mapPrdBenIdExist = new Map<Id,List<String>>();
        if(prdBenLst.size()>0){
            for(ProdBenefit__c prdBen:prdBenLst){
                if(mapPrdBenIdExist.get(prdBen.Product__r.Id)==null){
                   mapPrdBenIdExist.put(prdBen.Product__r.Id,new List<String>());
                }
                mapPrdBenIdExist.get(prdBen.Product__r.Id).add(prdBen.Benefit_Package_ID__c);
            }
            system.debug('mapPrdBenId'+mapPrdBenIdExist);
        }
        
        for(Id prdId:prdIdSet){
            if(mapPrdBenIdExist.containsKey(prdId)){
                mapPrdBenId.put(prdId,mapPrdBenIdExist.get(prdId));        
            }else{
                mapPrdBenId.put(prdId,new List<String>());
            }
        }
         
        /*** Geetha PC-15498 End***/
    }
    
    public void showPopup1()
    {
        totalRecsForCase=0;
        OffsetSize=0;
        LimitSize=3;
        if(ImplChoosed!=null){
            totalRecsForCase = [select count() from Implementation_Notes__c where Parent_Impl_Case_Id__c=:ImplChoosed and RecordTypeId=:implNoteRecordTypeId];
        }      
        //noteToDisplay = [select id,createdById,createdDate,CreatedBy.name,Implementation_Notes__c,Parent_Impl_Case_Id__c,Title__c,Opportunity__c from Implementation_Notes__c where Parent_Impl_Case_Id__c =:ImplChoosed AND Opportunity__c=:OppId and RecordTypeId=:implNoteRecordTypeId order by createdDate desc Limit 3];
        noteToDisplay = notesLst(OffsetSize);
        displayPopup = true;  
    }
    public void closePopup()
    {      
        displayPopup = false;  
    }
    public void FirstPage()
   {
        OffsetSize = 0;
        noteToDisplay = notesLst(OffsetSize);        
        //noteToDisplay = [select id,createdById,createdDate,CreatedBy.name,Implementation_Notes__c,Parent_Impl_Case_Id__c,Title__c,Opportunity__c from Implementation_Notes__c where Parent_Impl_Case_Id__c =:ImplChoosed AND Opportunity__c=:OppId and RecordTypeId=:implNoteRecordTypeId order by createdDate desc LIMIT :LimitSize OFFSET :OffsetSize];               
   }
   public void previous()
   {
        OffsetSize = OffsetSize-LimitSize;
        noteToDisplay = notesLst(OffsetSize);
        //noteToDisplay = [select id,createdById,createdDate,CreatedBy.name,Implementation_Notes__c,Parent_Impl_Case_Id__c,Title__c,Opportunity__c from Implementation_Notes__c where Parent_Impl_Case_Id__c =:ImplChoosed AND Opportunity__c=:OppId and RecordTypeId=:implNoteRecordTypeId order by createdDate desc LIMIT :LimitSize OFFSET :OffsetSize];
   }
   public void next()
   {
        OffsetSize = OffsetSize + LimitSize;
        noteToDisplay = notesLst(OffsetSize);
        //noteToDisplay = [select id,createdById,createdDate,CreatedBy.name,Implementation_Notes__c,Parent_Impl_Case_Id__c,Title__c,Opportunity__c from Implementation_Notes__c where Parent_Impl_Case_Id__c =:ImplChoosed AND Opportunity__c=:OppId and RecordTypeId=:implNoteRecordTypeId order by createdDate desc LIMIT :LimitSize OFFSET :OffsetSize];        
   }
   public void LastPage()
   {
        if(math.mod(totalRecsForcase,LimitSize)==0)
        {
            OffsetSize =totalrecsForCase-LimitSize;
        }
        else
        {
            OffsetSize = totalrecsForCase-math.mod(totalRecsForCase,LimitSize);

        }
        noteToDisplay = notesLst(OffsetSize);
        //noteToDisplay = [select id,createdById,createdDate,CreatedBy.name,Implementation_Notes__c,Parent_Impl_Case_Id__c,Title__c,Opportunity__c from Implementation_Notes__c where Parent_Impl_Case_Id__c =:ImplChoosed AND Opportunity__c=:OppId and RecordTypeId=:implNoteRecordTypeId order by createdDate desc LIMIT :LimitSize OFFSET :OffsetSize];        
    }
    public boolean getprev()
    {
        if(OffsetSize == 0)
        return true;
        else
        return false;
    }
    public boolean getnxt()
    {
        System.debug(LoggingLevel.ERROR, 'OffsetSize: ' + OffsetSize + ',LimitSize: ' + LimitSize + ',totalRecsForCase: ' + totalRecsForCase);
        if((OffsetSize + LimitSize) >= totalRecsForCase)
        return true;
        else
        return false;
    }
    
    public List<Implementation_Notes__c> notesLst(Integer offset){//geetha for query optimisation
        List<Implementation_Notes__c> ntLst = [select id,createdById,createdDate,CreatedBy.name,Implementation_Notes__c,Parent_Impl_Case_Id__c,Title__c,Opportunity__c from Implementation_Notes__c where Parent_Impl_Case_Id__c =:ImplChoosed AND Opportunity__c=:OppId and RecordTypeId=:implNoteRecordTypeId order by createdDate desc LIMIT :LimitSize OFFSET :offset];
        return ntLst;
    }//till here for query optimisation
    
    public void FirstPageAll()
   {
        OffsetSizeAll = 0; 
        noteToDisplayAll = notesLstAll(OffsetSizeAll);                
        //noteToDisplayAll = [select id,createdById,createdDate,Opportunity__c,CreatedBy.name,Implementation_Notes__c,Parent_Impl_Case_Id__c,Title__c from Implementation_Notes__c where Opportunity__c=:OppId and RecordTypeId=:implNoteRecordTypeId order by createdDate desc LIMIT :LimitSizeAll OFFSET :OffsetSizeAll];        
   }
   public void previousAll()
   {
        OffsetSizeAll = OffsetSizeAll-LimitSizeAll;
        noteToDisplayAll = notesLstAll(OffsetSizeAll);         
        //noteToDisplayAll = [select id,createdById,createdDate,Opportunity__c,CreatedBy.name,Implementation_Notes__c,Parent_Impl_Case_Id__c,Title__c from Implementation_Notes__c where Opportunity__c=:OppId and RecordTypeId=:implNoteRecordTypeId order by createdDate desc LIMIT :LimitSizeAll OFFSET :OffsetSizeAll];
      
   }
   public void nextAll()
   {
        OffsetSizeAll = OffsetSizeAll + LimitSizeAll;
        noteToDisplayAll = notesLstAll(OffsetSizeAll);         
        //noteToDisplayAll = [select id,createdById,createdDate,Opportunity__c,CreatedBy.name,Implementation_Notes__c,Parent_Impl_Case_Id__c,Title__c from Implementation_Notes__c where Opportunity__c=:OppId and RecordTypeId=:implNoteRecordTypeId order by createdDate desc LIMIT :LimitSizeAll OFFSET :OffsetSizeAll];
   }
   public void LastPageAll()
   {
        if(math.mod(totalRecsForOppty,LimitSizeAll)==0)
        {
            OffsetSizeAll =totalRecsForOppty-LimitSizeAll;
        }
        else
        {
            OffsetSizeAll = totalRecsForOppty-math.mod(totalRecsForOppty,LimitSizeAll);

        }
        noteToDisplayAll = notesLstAll(OffsetSizeAll);         
        //noteToDisplayAll = [select id,createdById,createdDate,Opportunity__c,CreatedBy.name,Implementation_Notes__c,Parent_Impl_Case_Id__c,Title__c from Implementation_Notes__c where Opportunity__c=:OppId and RecordTypeId=:implNoteRecordTypeId order by createdDate desc LIMIT :LimitSizeAll OFFSET :OffsetSizeAll];
    }
    public boolean getprev1()
    {
        if(OffsetSizeAll == 0)
        return true;
        else
        return false;
    }
    public boolean getnxt1()
    {
        if((OffsetSizeAll + LimitSizeAll) >= totalRecsForOppty)
        return true;
        else
        return false;
    }
    //till here for 13439
    
    public List<Implementation_Notes__c> notesLstAll(Integer offset){//geetha for query optimisation
        List<Implementation_Notes__c> ntLst = [select id,createdById,createdDate,Opportunity__c,CreatedBy.name,Implementation_Notes__c,Parent_Impl_Case_Id__c,Title__c from Implementation_Notes__c where Opportunity__c=:OppId and RecordTypeId=:implNoteRecordTypeId order by createdDate desc LIMIT :LimitSizeAll OFFSET :offset];
        return ntLst;
    }//till here for query optimisation
    
    // Normal IMPL Button Action
    public PageReference hideSection(){
        try{
            sendLstOLI.clear();
            for(OpportunityLineItem oli : implOLI){
                if(oli.Parent_Impl_Case_Id__c == null && oli.Parent_Impl_Case_Status__c != 'Resolved-Withdrawn'){
                    selProdIds.add(oli.Product2Id);
                    sendLstOLI.add(oli);
                    if(oli.RFP_Case_Id__c != null){
                        RFPid.add(oli.RFP_Case_Id__c);
                    }
                    selectedAccountId = oli.Opportunity.AccountId;
                }
            }
            if(OpptyNRC.Type=='New'){//14067
                system.debug('hiiii iffff New');
                for(OpportunityLineItem sendOLI:sendLstOLI){
                    if(!mapQuoteOli.isEmpty() && mapQuoteOli.get(sendOLI.Quote__c)!=null){                                            
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please make a decission on all the plans in the quote to continue with Implementation');
                        ApexPages.addMessage(myMsg);  
                        return null;                            
                    }
                }
            }
            else if(OpptyNRC.Type=='Renewal' || OpptyNRC.Type=='Change'){
                system.debug('hiiii iffff Renewal');
                if(decPendOLI.size()>0){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please make a decission on all the plans in the quote to continue with Implementation');
                    ApexPages.addMessage(myMsg);  
                    return null;
                }
            } //Till here for 14067
            if(RFPid != null){
                quoteList = [select id,Sales_Notes__c,UW_Notes__c,RFP_Case_Id__c  from Quote where RFP_Case_Id__c IN: RFPid];
            }
            system.debug('quoteList'+quoteList);
            hide = false;
            if(Test.isRunningTest() && P2EhGlobalUtil.isNegScenario){
                    throw new P2EException('P2EcPlanDesignOpportunityList - hideSection()','','Test','Manual');
           }
        }catch(Exception e){
            P2EException pe;
            String errorcode;
            Datetime cDT = System.now();
            errorcode = cDT.format('YYYYMMDDhhmmss');
            if(e instanceof P2EException){
               pe = (P2EException)e;
               if(pe.errorcode==null || pe.errorcode==''){
                   pe.errorcode=errorcode;
               }
               if(pe.stackTrace == null || pe.stackTrace==''){
                   pe.stackTrace = e.getStackTraceString();
               }
               pe.addSource('P2EcPlanDesignOpportunityList - hideSection()');
            }
            else{ 
               pe = new P2EException('P2EcPlanDesignOpportunityList - hideSection()',errorcode,e);                           
            }
            pe.logException();
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please contact Administrator with ErrorCode: '+ pe.errorcode);
            ApexPages.addMessage(myMsg);  
            return null;                   
       }
        return null;
    }
    
    public PageReference cancel(){
        hide = true;
        return null;
    }
    
    // Re-IMPL Button
    public PageReference reImpl(){
        try{
            sendLstOLI.clear();
            for(OpportunityLineItem oli : reimplOLI){
                if(oli.RFP_Case_Id__c != null){
                    RFPid.add(oli.RFP_Case_Id__c);
                    selectedAccountId = oli.Opportunity.AccountId;
                    if(oli.Parent_Impl_Case_Status__c != 'Resolved-Withdrawn'){ // Added for PC-12024                    
                        selProdIds.add(oli.Product2Id);
                    }
                    sendLstOLI.add(oli);
                }
            }
             if(OpptyNRC.Type=='New'){//14067
                system.debug('hiiii iffff New');
                for(OpportunityLineItem sendOLI:sendLstOLI){
                    if(!mapQuoteOli.isEmpty() && mapQuoteOli.get(sendOLI.Quote__c)!=null){                                            
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please make a decission on all the plans in the quote to continue with Implementation');
                        ApexPages.addMessage(myMsg);  
                        return null;                            
                    }
                }
            }
            else if(OpptyNRC.Type=='Renewal' || OpptyNRC.Type=='Change'){
                system.debug('hiiii iffff Renewal');
                if(decPendOLI.size()>0){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please make a decission on all the plans in the quote to continue with Implementation');
                    ApexPages.addMessage(myMsg);  
                    return null;
                }
            }//Till here for 14067
            if(RFPid != null){
                quoteList = [select id,Sales_Notes__c,UW_Notes__c,RFP_Case_Id__c  from Quote where RFP_Case_Id__c IN: RFPid];
            }
            system.debug('quoteList reImpl'+quoteList);
           set<String> parImplCaseId=new set<String>();//Re-IMPL
           set<String> parImplCaseStatus=new set<String>();//Re-IMPL
           List<Integer> parImplCaseIdLst = new List<Integer>();//Re-IMPL 
           String parImCaseToAssign = '';//Re-IMPL                                                        
           Map<String,String> caseIdStatusMap = new Map<String,String>();//Re-IMPL
           List<OpportunityLineItem> oliLstToUpdate = new List<OpportunityLineItem>();//Re-IMPL
           String parImplCaseIdNewCh = '';//Re-IMPL 
           List<Case> csLst = [select id,UW_Case_ID__c,status from case where type='Implementation' and Ad_hoc__c=false and Related_Opportunity__c=:OppId and status!='Withdrawn' and UW_Case_ID__c!=null];//Re-IMPL          
           for(OpportunityLineItem oli : sendlstOLI){
               if(oli.Par_Impl_case_Id_Hide__c!=null){  
                    /*if(oli.Parent_Impl_Case_Id__c!=null && (oli.Opportunity.type=='New' || oli.Opportunity.type=='Change')){//Re-IMPL start
                       parImplCaseIdNewCh = oli.Parent_Impl_Case_Id__c;
                       parImplCaseStatusNewCh = oli.Parent_Impl_Case_Status__c;
                       oli.Par_Impl_case_Id_Hide__c = oli.Parent_Impl_Case_Id__c;
                       oli.Par_Impl_case_status_Hide__c = oli.Parent_Impl_Case_Status__c;
                       oliLstToUpdate.add(oli);
                    }*/
                    parImplCaseIdNewCh = oli.Par_Impl_case_Id_Hide__c;
                    if(oli.Opportunity.type=='Renewal'){
                       for(case cs:csLst ){
                           if((oli.Parent_Impl_Case_Id__c!=null && oli.Parent_Impl_Case_Id__c==cs.UW_Case_ID__c) || oli.Par_Impl_case_Id_Hide__c==cs.UW_Case_ID__c){
                               parImplCaseId.add(cs.UW_Case_ID__c); 
                               parImplCaseStatus.add(cs.status);  
                               caseIdStatusMap.put(cs.UW_Case_ID__c,cs.status);
                           }
                        }                                 
                    }
               }
            }
            if((OpptyNRC.type=='New' || OpptyNRC.type=='Change') && parImplCaseIdNewCh !=null){
                Case cs = [select id,UW_Case_ID__c,status from case where UW_Case_ID__c=:parImplCaseIdNewCh];
                for(OpportunityLineItem oli : sendlstOLI){
                    oli.Par_Impl_case_Id_Hide__c = cs.UW_Case_ID__c;
                    oli.Par_Impl_case_status_Hide__c = cs.status;
                    oliLstToUpdate.add(oli);
                } 
            }                                                                                 
            if(parImplCaseId.size()>1){
               if(parImplCaseStatus.size()==1){
                   for(String caseId:parImplCaseId){
                       parImplCaseIdLst.add(integer.valueof(caseId.remove('IM-')));
                   }                                
                   parImplCaseIdLst.sort();       
                   Integer lastIndex = parImplCaseIdLst.size()-1;                    
                   parImCaseToAssign='IM-'+parImplCaseIdLst[lastIndex];
               } 
               else if(parImplCaseStatus.size()>1){
                    for(OpportunityLineItem oli : sendlstOLI){
                        if(oli.Parent_Impl_Case_Status__c=='Resolved-Completed'){
                           parImCaseToAssign=oli.Parent_Impl_Case_Id__c;
                           break;
                        }
                    }
               }
               for(OpportunityLineItem oli : sendlstOLI){                                 
                   oli.Par_Impl_case_Id_Hide__c = parImCaseToAssign;
                   oli.Par_Impl_case_status_Hide__c = caseIdStatusMap.get(parImCaseToAssign);
                   oliLstToUpdate.add(oli);
               }                            
            }
            else if(parImplCaseId.size()==1){
                for(String caseId:parImplCaseId){
                    parImCaseToAssign=caseId;
                }
                for(OpportunityLineItem oli : sendlstOLI){                                 
                   oli.Par_Impl_case_Id_Hide__c = parImCaseToAssign;
                   oli.Par_Impl_case_status_Hide__c = caseIdStatusMap.get(parImCaseToAssign);
                   oliLstToUpdate.add(oli);
               } 
            }            
            if(oliLstToUpdate.size()>0){
                update oliLstToUpdate;
            }//Re-IMPL End
            hide = false;
            if(Test.isRunningTest() && P2EhGlobalUtil.isNegScenario){
                    throw new P2EException('P2EcPlanDesignOpportunityList - reImpl()','','Test','Manual');
           }
        }catch(Exception e){
            P2EException pe;
            String errorcode;
            Datetime cDT = System.now();
            errorcode = cDT.format('YYYYMMDDhhmmss');
            if(e instanceof P2EException){
               pe = (P2EException)e;
               if(pe.errorcode==null || pe.errorcode==''){
                   pe.errorcode=errorcode;
               }
               if(pe.stackTrace == null || pe.stackTrace==''){
                   pe.stackTrace = e.getStackTraceString();
               }
               pe.addSource('P2EcPlanDesignOpportunityList - reImp()');
            }
            else{ 
               pe = new P2EException('P2EcPlanDesignOpportunityList - reImp()',errorcode,e);                           
            }
            pe.logException();
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please contact Administrator with ErrorCode: '+ pe.errorcode);
            ApexPages.addMessage(myMsg);  
            return null;                   
       }
        return null;
    }
    
    // Future Purpose - Not currently used
    public class wrapperOLI{
        public OpportunityLineItem objoli {get;set;}
        Public boolean isSelectedOLI {get; set;}
    } 
    
    //13439
    public PageReference addNotes(){
        List<String> oliIdsList = new List<String>();        
        Opportunity Oppty = Database.Query(P2EhUtility.getQuery('Opportunity') + ' Where Id = \'' + OppId + '\' Limit 1');
        if(salesNotes == null || salesNotes == ''){ 
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please add SalesNotes');
            ApexPages.addMessage(myMsg);
            return null;
        }
            
            for(OpportunityLineItem oliNew : sendLstOLI){
                oliIdsList.add(oliNew.Id);
            }
            String fnlList = String.join(oliIdsList,',');                    
            if(salesNotes != null){   
            noteInfo = new Implementation_Notes__c();            
            noteInfo.Implementation_Notes__c = salesNotes;
            noteInfo.Opportunity__c= OppId; 
            noteInfo.Title__c = 'Sales Notes for Implementation';
            noteInfo.OLI_IDs__c = fnlList;
            noteInfo.RecordTypeId = implNoteRecordTypeId;           
            insert noteInfo;             
            oppty.Sales_Notes_for_Implementation__c = salesNotes;
            update oppty;
            salesNotes = Null;
            OffsetSizeAll=0;        
            LimitSizeAll=3;
            noteToDisplayAll = notesLstAll(OffsetSizeAll); //added by Geetha for query optimisation
            totalRecsForOppty = [select count() from Implementation_Notes__c where Opportunity__c=:OppId and RecordTypeId=:implNoteRecordTypeId]; //443 to 446 commented by geetha for query optimisation                                               
        }
        return null;
     }     
     //till here for 13439
    
    // Submit Button
    public PageReference doImplCallout(){
        Set<String> RFPId = new Set<String>();//GC Re-Rate
        Set<Id> setPrdIds = new set<Id>();//GC Re-Rate
        Set<Id> qIds = new set<Id>();//GC Re-Rate
        Opportunity selOpp;
        List<Implementation_Notes__c> noteInfoList=new List<Implementation_Notes__c>();//13439
        Account selAcc;
        PageReference pageRef;
        try{
            selOpp = Database.Query(P2EhUtility.getQuery('Opportunity') + ' Where Id = \'' + OppId + '\' Limit 1');
            selAcc = Database.Query(P2EhUtility.getQuery('Account') + ' Where Id = \'' + selOpp.AccountId + '\' Limit 1');
            noteInfoList = [select id,Implementation_Notes__c,OLI_IDs__c,Parent_Impl_Case_Id__c,Opportunity__c,Title__c from Implementation_Notes__c where Opportunity__c=:OppId and RecordTypeId=:implNoteRecordTypeId];//13439
            //selOpp.Sales_Notes_for_Implementation__c = opp.Sales_Notes_for_Implementation__c;
            selOpp.Description = opp.Description;
           /* if(selOpp.type == 'Change'){
                  selOpp.stagename  = 'Change Accepted';              
            }  */
            P2EhPegaCallouts call = new P2EhPegaCallouts(selAcc, selOpp, caseInsert, selProdIds);
            P2EwImplResponse implResp = (P2EwImplResponse) call.getOSRRate('IMPL');
            
            system.debug('implResp:: ' + implResp);

            if(implResp!=null && implResp.Implementation.Error!=null){//Re-IMPL ErrorMsg Start               
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error Message from PEGA:'+implResp.Implementation.Error.ErrorMessage+'. Error Code:'+implResp.Implementation.Error.ErrorCode);
                   ApexPages.addMessage(myMsg); 
                   return null; 
            }//Re-IMPL ErrorMsg Start
            else{//Re-IMPL ErroeMsg
                //String grpNum;
                String pImplCaseId;
                set<Id> oliId = new set<Id>();//13439
                for(OpportunityLineItem oli : sendlstOLI){
                    oliId.add(oli.Id);//13439
                    RFPId.add(oli.RFP_Case_Id__c);//GC Re-Rate
                    setPrdIds.add(oli.product2Id);//GC Re-Rate
                    if(oli.Par_Impl_case_Id_Hide__c!=null){
                        //grpNum = oli.Group_Number__c;
                        pImplCaseId = oli.Par_Impl_case_Id_Hide__c;
                    }
                }
                Map<Id, Quote> quoteList = new Map<Id, Quote>([select id,name,Sales_Notes__c,UW_Notes__c,RFP_Case_Id__c from quote where RFP_Case_Id__c in: RFPId]);//GC Re-Rate start
                if(quoteList.size()>0){
                    qIds=quoteList.keySet();
                }//GC Re-Rate End
                system.debug('sendlstOLI :: ' + sendlstOLI);
                system.debug('pImplCaseId :: ' + pImplCaseId);
                if(pImplCaseId!=null){
                    case case1 = [Select Id, Group__c, Related_Opportunity__c, Related_Opportunity__r.Name, Related_Opportunity__r.Type, Related_Opportunity__r.AccountId, Status, Parent_Impl_Case_Id__c, Parent_Impl_Case_Status__c, Subject From Case Where Parent_Impl_Case_Id__c =: pImplCaseId Limit 1];
                    case1.Status = 'Pending-Review';
                    Set<String> grpNbr = new Set<String>();
                    Set<ID> RenoppId = new set<ID>();
                    if(case1.Group__c!=null){
                        for(String grp : case1.Group__c.split(',')){
                            grpNbr.add(grp);
                        }
                    }
                    /*if(!grpNbr.isEMpty()){//commented for 3.1 Start
                         List<Contract> cntrt = [select id, AccountId, Status, Name, Group_Number__c,  
                                            StartDate, EndDate, ContractNumber, contractterm, Opportunity__c,Renewal_Opportunity__c,
                                            Opportunity__r.Type,Renewal_Opportunity__r.id,Change_Opportunity__c,Renewal_clause__c from Contract 
                                            where Group_Number__c in: grpNbr and (Opportunity__c =: OppId or (Change_Opportunity__c!=null and Change_Opportunity__r.Id=:OppId))];//updated by geetha for PC-13178
                        Id RenOpptyId;
                        Set<Id> cId = new Set<Id>(); // Added by Swetha for Re-IMPL Process
                        Set<Id> prodId = new Set<Id>(); // Added by Swetha for Re-IMPL Process
                        if(cntrt!=null && !cntrt.isEmpty()){
                            for(Contract cnt: cntrt){
                                if(cnt.Change_Opportunity__c!=null && cnt.Change_Opportunity__c==OppId){
                                    RenOpptyId = cnt.Renewal_Opportunity__c;                                
                                    break;
                                }       
                                if(cnt.Renewal_Opportunity__c!=null){                               
                                    RenoppId.add(cnt.Renewal_Opportunity__r.id);// PC-14058 by karthik
                                    system.debug('***'+RenoppId);
                                }                 
                            }
                           
                            if(RenoppId!=null || !RenoppId.isEmpty()){
                            List<opportunity> Roppty = [Select id from opportunity where id in:RenoppId];// PC-14058 by karthik
                             system.debug('@@@'+RenoppId);
                             P2EhUtility.putOpptyDeleteTriggerExecuted();//PC-14058
                             delete Roppty;// PC-14058 by karthik
                            }
                            /***Added by Swetha for Re-IMPL Process Start
                             for(Contract cnt: cntrt){
                                 cId.add(cnt.id);
                             }
                             List<ContractProduct__c> cpList = [select id, Contract__c, Product__c from ContractProduct__c where Contract__c in: cId];
                             if(cpList.size()>0){
                                 for(ContractProduct__c cp:cpList){
                                        prodId.add(cp.Product__c);
                                 }
                                 List<ProdBenefit__c> prdBenLst = [select id, Product__c from ProdBenefit__c where Product__c in: prodId];
                                 if(prdBenLst.size()>0){
                                     delete prdBenLst;
                                 }
                                 delete cpList;
                             }
                             /*** Re-IMPL Process End
                             
                             delete cntrt;//PC-13178 by Geetha
                        }
                        List<Contract> cntrt1 = [select id, AccountId, Status, Name, Group_Number__c,  
                                            StartDate, EndDate, ContractNumber, contractterm, Opportunity__c,Renewal_Opportunity__c,Renew_Oppty_Hide__c,
                                            Opportunity__r.Type, Renewal_clause__c from Contract 
                                            where Group_Number__c in: grpNbr and (Renewal_Opportunity__c =: OppId or (Renew_Oppty_Hide__c!=null and Renew_Oppty_Hide__r.Id=:RenOpptyId))]; //PC-13178 by Geetha
                        if(cntrt1!=null && !cntrt1.isEmpty()){
                            for(Contract cn : cntrt1){
                                cn.Status = 'Activated';
                                if(cn.Renew_Oppty_Hide__c!=null && cn.Renewal_Opportunity__c==null && cn.Renew_Oppty_Hide__c==RenOpptyId){
                                    cn.Renewal_Opportunity__c = cn.Renew_Oppty_Hide__c;
                                    cn.Renew_Oppty_Hide__c=null;
                                }
                            }
                            //-- Added the logic for Heat:1740298
                            //Modified By: Parthiban P, Modified on 18-03-2016                    
                            P2EhUtility.putContractTriggerToBeExecuted();//Preventing contract before update trigger execution.
                            //-- Ending code for Heat:1740298                    
                            update cntrt1;
                        }//PC-13178 by Geetha
                    }*/ //commented for 3.1 End
                    update case1;
                    /**** Added for Re-IMPL Process Start****/                               
                    if(P2EhPegaCallouts.rImplCaseId!=null){
                        String implCase=P2EhPegaCallouts.rImplCaseId;
                        case orphan_case = [Select Id, Group__c, Related_Opportunity__c, Related_Opportunity__r.Name, Related_Opportunity__r.Type, Related_Opportunity__r.AccountId, Status, Parent_Impl_Case_Id__c, Parent_Impl_Case_Status__c, Subject From Case Where Parent_Impl_Case_Id__c =: implCase Limit 1];
                        orphan_case.Status = 'Resolved-Completed';
                        update orphan_case;
                    }
                    /**** Re-IMPL Process End****/
                }
                
                P2EhDML dml = new P2EhDML();
                
                List<String> ProdIds;
                Map<String, List<String>> groupProdMap = new Map<String, List<String>>();
                if(Test.isRunningTest())
                {
                    P2EwImplResponse.QQImplementation Implementation = new P2EwImplResponse.QQImplementation();
                    P2EwImplResponse.QQGroupInfo qqinfo = new P2EwImplResponse.QQGroupInfo();
                    qqinfo.CaseID = 'PR-123';
                    P2EwImplResponse.QQGroupInfo[] qlist =new List<P2EwImplResponse.QQGroupInfo> {qqinfo};
                    Implementation.GroupInfo = qlist;    
                    implResp = new P2EwImplResponse(Implementation);
                }
                if(implResp!=null){
                    //Modified by Parthi for PC-8892 for restricting multiple case creation for re-implementation        
                    List<Case> isReImplCase = new List<Case>();
                    isReImplCase = [Select Id, UW_Case_Id__c From Case Where UW_Case_Id__c =: implResp.Implementation.GroupInfo[0].CaseID];
                    if(isReImplCase.size() > 0){
                        isReImplCase[0].Status = implResp.Implementation.GroupInfo[0].CaseStatus;
                        isReImplCase[0].RFP_IMPLSubmittedBy__c = UserInfo.getUserId();
                        dml.toDMLlist.add(isReImplCase[0]);
                        if(caseInsert != Null && caseInsert.Id != Null){
                            delete caseInsert;
                        }
                    }else{        
                        if(caseInsert != Null && caseInsert.Id != Null){
                              if(selOpp.stagename == 'Renewal Initiated') {
                                caseInsert.Subject = 'EarlyRenewal IMPL Case Record :' + implResp.Implementation.GroupInfo[0].CaseID; 
                              } else {
                                caseInsert.Subject = selOpp.Type + ' IMPL Case Record :' + implResp.Implementation.GroupInfo[0].CaseID; 
                              }
                              caseInsert.Status = implResp.Implementation.GroupInfo[0].CaseStatus;
                              caseInsert.Parent_Impl_Case_Id__c = implResp.Implementation.GroupInfo[0].CaseID;
                              caseInsert.UW_Case_Id__c = implResp.Implementation.GroupInfo[0].CaseID;
                              caseInsert.RFP_IMPLSubmittedBy__c = UserInfo.getUserId();
                              dml.toDMLlist.add(caseInsert);
                        }
                    }
                    
                    //13439
                    if((!noteInfoList.isEmpty() || noteInfoList.size()>0) && (!oliId.isEmpty() || oliId.size()>0)){
                        set<id> notIdSet = new set<id>();
                        for(String oliId1:oliId){                    
                            for(Implementation_Notes__c noteInfo1:noteInfoList){
                                 if(noteInfo1.OLI_IDs__c!=null && noteInfo1.OLI_IDs__c!='' && noteInfo1.OLI_IDs__c.contains(oliId1) && !notIdSet.contains(noteInfo1.Id)){
                                     notIdSet.add(noteInfo1.Id);           
                                     noteInfo1.Parent_Impl_Case_Id__c = implResp.Implementation.GroupInfo[0].CaseID;
                                 }
                            } 
                        }                
                        update noteInfoList;
                    }
                    //till here for 13439
                    
                    List<OpportunityLineItem> OLItoUpdate = new List<OpportunityLineItem>();
                    Set<Id> oliIds = new Set<Id>();
                    for(P2EwImplResponse.QQGroupInfo groupInfo : implResp.Implementation.GroupInfo){
                        for(OpportunityLineItem oli : sendlstOLI){
                            oli.Parent_Impl_Case_Id__c = groupInfo.CaseID;
                            oli.Parent_Impl_Case_Status__c = groupInfo.CaseStatus;
                            oli.Impl_Case_Id__c = null;
                            oli.Impl_Case_Status__c = null;
                            oli.IsReRate__c = false;
                            oliIds.add(oli.id);
                            //oli.Group_Number__c = groupInfo.GroupNumber;
                            dml.toDMLlist.add(oli);
                            if(groupProdMap.get(groupInfo.GroupNumber)!=null){
                                ProdIds = groupProdMap.get(groupInfo.GroupNumber);
                            }else{
                                ProdIds = new List<String>();
                            }
                            ProdIds.add(oli.product2.PlanID__c);
                            groupProdMap.put(groupInfo.GroupNumber, ProdIds);
                        }
                    }
                    system.debug('pImplCaseId :: ' + pImplCaseId);
                    if(reimplOLI!=null && !reimplOLI.isEmpty() && pImplCaseId!=null){
                        system.debug('into new if');
                        system.debug('pImplCaseId :: ' + pImplCaseId);
                        for(OpportunityLineItem oli : [select id,IsRerate__c from OpportunityLineItem where Par_Impl_case_Id_Hide__c =: pImplCaseId]){
                            if(!oliIds.contains(oli.id)){
                                oli.IsReRate__c = false;
                                dml.toDMLlist.add(oli);
                            }
                        }
                    }
                    selAcc.RecordTypeId = P2EhUtility.getRecordTypeId('Account','Implementation');
                    dml.toDMLlist.add(selAcc);
                    if(selOpp.Type != 'Renewal'){
                        selOpp.RecordTypeId = P2EhUtility.getRecordTypeId('Opportunity','Implementation');
                    }else{
                        selOpp.RecordTypeId = P2EhUtility.getRecordTypeId('Opportunity','Renewal Implementation');
                    }
                    dml.toDMLlist.add(selOpp);
                    dml.action = P2EenDML.Updation;
                    //try{
                        dml.doDML();
                    /*}
                    catch(P2EException e){
                        e.addSource('P2EcPlanDesignOpportunityList - doImplCallout()');
                        e.logException();
                    }*/  
                    //Notes to insert for Oppty
                    /*if(selOpp.Sales_Notes_for_Implementation__c != null){
                        system.debug('salesnotes*'+selOpp.Sales_Notes_for_Implementation__c);
                        note = new Note();
                        note.Title = 'SalesNotes for Implementation';
                        note.Body= selOpp.Sales_Notes_for_Implementation__c;
                        note.ParentId = selOpp.Id;
                        insert note; 
                     }*/
                     List<Ratesheet__c> rsLstToUpdate=new List<Ratesheet__c>();//GC Re-Rate Start
                     List<Ratesheet__c> rsLst=Database.Query(P2EhUtility.getQuery('Ratesheet__c') + ' WHERE Product2__c in: setPrdIds');
                     for(Ratesheet__c rs:rsLst){
                         if(rs.Type__c!='Activate' && rs.isSentToImplementation__c==true && rs.isCurrentRatesheet__c==true){
                             rs.isCurrentRatesheet__c=false;
                             rsLstToUpdate.add(rs);
                         }
                         if(rs.Type__c=='Activate' && rs.isSentToImplementation__c==false && rs.isCurrentRatesheet__c==false && qIds.contains(rs.Response_Quote__c)){
                             rs.isSentToImplementation__c=true;
                             rs.isCurrentRatesheet__c=true;
                             rsLstToUpdate.add(rs);
                         }
                     }
                     if(rsLstToUpdate.size()>0){
                         update rsLstToUpdate;
                     }//GC Re-Rate End
                }
                //return null;
                pageRef = new PageReference('/apex/P2EvPlanDesignOpportunityList?id='+ oppId);
                pageRef.setRedirect(true);
                //PageReference pageRef = new PageReference('/'+oppId);
            }//Re-IMPL ErrorMsg
        }catch(Exception e){
            if(qt.Is_Rerated_quote__C==true){
                Id approvalCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('QA_Approval_Case').getRecordTypeId();//QA WF
                Case qaCase = [SELECT Id,OwnerId,CreatedbyId,Createdby.Email,Quote__c,UW_Case_ID__c,Quote_Link__c,status,AccountId,QAApprovedAndNotImplemented__c FROM Case Where RecordTypeId=:approvalCaseRecordTypeId AND Quote__c=:qt.Id AND Related_Opportunity__c=:oppId Limit 1];
                Group que=[select Id from Group where  Type = 'Queue' AND NAME = 'Sales QA Approver Queue'];
                qaCase.OwnerId=que.Id;
                qaCase.status=Label.QA_Approval_Pending;
                update qaCase;
            }
            P2EException pe;
            String errorcode;
            Datetime cDT = System.now();
            errorcode = cDT.format('YYYYMMDDhhmmss');
            if(e instanceof P2EException){
               pe = (P2EException)e;
               if(pe.errorcode==null || pe.errorcode==''){
                   pe.errorcode=errorcode;
               }
               if(pe.stackTrace == null || pe.stackTrace==''){
                   pe.stackTrace = e.getStackTraceString();
               }
               pe.addSource('P2EcPlanDesignOpportunityList - doImplCallout()');
            }
            else{ 
               pe = new P2EException('P2EcPlanDesignOpportunityList - doImplCallout()',errorcode,e);                           
            }
            pe.logException();
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please contact Administrator with ErrorCode: '+ pe.errorcode);
            ApexPages.addMessage(myMsg);  
            return null;                   
       }
        return pageRef;
    }

    public PageReference CreateCase() {
    RecordType implementationRecordType;
      try{
          implementationRecordType = [select id from RecordType where sObjectType = 'Case' and name ='Implementation'];
          caseInsert = new Case();
          caseInsert.Subject = 'IMPL Case Record :';
          caseInsert.AccountId = selectedAccountId;
          caseInsert.Related_Opportunity__c = OppId;
          system.debug('acc****'+caseInsert.AccountId);
          system.debug('Opp****'+caseInsert.Related_Opportunity__c);
          if(implementationRecordType != null){
              caseInsert.recordTypeId = implementationRecordType.Id;
          }
          insert caseInsert;
          insertTeamMember(); 
          
           /** code updated by rajesh - workflow NotifySalesAnnouncement  **/
          Opportunity oppl = [select id, StageName,Workflow_Stage__c,IM_Initiated_Count__c, type from Opportunity where Id =: OppId];
          if(oppl.Workflow_Stage__c == Label.Sales_Stages_Decision_won && oppl.Type == 'New') {
              if(oppl.IM_Initiated_Count__c != Null){
                  oppl.IM_Initiated_Count__c = oppl.IM_Initiated_Count__c + 1;
              }
              update oppl;
          }    
          /** Code End **/
          
      }catch(Exception e){
            P2EException pe;
            String errorcode;
            Datetime cDT = System.now();
            errorcode = cDT.format('YYYYMMDDhhmmss');
            if(e instanceof P2EException){
               pe = (P2EException)e;
               if(pe.errorcode==null || pe.errorcode==''){
                   pe.errorcode=errorcode;
               }
               if(pe.stackTrace == null || pe.stackTrace==''){
                   pe.stackTrace = e.getStackTraceString();
               }
               pe.addSource('P2EcPlanDesignOpportunityList - CreateCase()');
            }
            else{ 
               pe = new P2EException('P2EcPlanDesignOpportunityList - CreateCase()',errorcode,e);                           
            }
            pe.logException();
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please contact Administrator with ErrorCode: '+ pe.errorcode);
            ApexPages.addMessage(myMsg);  
            return null;                   
       }
      return null;
    }


    public void autoimplcallout(P2EwWizCache cache){
        P2EhPegaCallouts call = new P2EhPegaCallouts(cache);
        P2EwImplResponse implResp = (P2EwImplResponse) call.getOSRRate('IMPL');
    

      taskList = [select id,whatid,subject,status from task where whatId =:OppId and subject='Renewal Notice response not received'];
      
      system.debug('tasklist'+taskList);
      
      if(taskList!=null){
          for(Task t:taskList)
          {
             if(t.Status!='Completed')
             {
                  t.Status='Completed';  
             
             } 
          }
          update taskList;
          system.debug('tasklist2'+taskList);
      }  
    }
    public void insertTeamMember(){
        Id opptId = ApexPages.currentPage().getParameters().get('id');
        Opportunity opp = [select Id,AccountId from Opportunity where id =: opptId];
        Account acc = [select Id,Name,RecordType.Name,Account_Manager__c from Account where Id =: opp.AccountId];
        system.debug('recordtype++++'+acc.RecordType.Name);
        if(acc.RecordType.Name == 'Prospect' || acc.RecordType.Name == 'Implementation'){
        system.debug('accMgr+++++'+acc.Account_Manager__c);
            if(acc.Account_Manager__c == null){
                List<User> sds = new List<User>();
                sds = [select id,name from user where userrole.Name='Director Sales South'];
                for(User sd : sds){
                    AccountTeamMember atm = new AccountTeamMember();
                    atm.userId = sd.Id;
                    atm.AccountId = acc.Id;
                    atm.TeamMemberRole = 'Sales Director';
                    //atm.AccountAccessLevel = 'All';
                    insert atm;
                    Task atmTask = new Task();
                    atmTask.OwnerId = sd.Id;
                    atmTask.ActivityDate = Date.today();
                    atmTask.WhatId = acc.Id;
                    atmTask.Account_Name__c = acc.Name;
                    atmTask.subject = 'Account Manager needs Update';
                    insert atmTask;
                }
            }   
        }
    }
    /*** Geetha PC-15498 Start ***/
    //Display the Benefit Package ID list on Pop-up
    public PageReference getBPList(){        
        prdBenLst = [select id,Benefit_Package__c,Benefit_Package_ID__c,Product__c from ProdBenefit__c where Product__r.Id =: selectedProdId];           
        displayPopupNew = true;
        return null;
    }
    //Close the pop-up
    public PageReference closePopupNew(){
        displayPopupNew = false;
        return null;
    }
    /*** Geetha PC-15498 End ***/
}