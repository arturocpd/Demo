public with sharing class DeploymentTriggerHelper {
    private static List<Promotion__c> promosToComplete = new List<Promotion__c>();
    private static List<Build_Task__c> bts = new List<Build_Task__c>();
    private static Set<Id> checkOnly = new Set<Id>();
    private static Map<String,Build_Task__c> taskMap = new Map<String,Build_Task__c>();
    private static Map<String,Org__c> orgMap = new Map<String,Org__c>();
    private static List<Deployment_History__c> history = new List<Deployment_History__c>();
    public static Map<Id,Id>promotionDeploymentIdsMap; 
    public static Map<Id,Promotion__c>deploymentPromotionsMap;    
    public static Map<Id,Id>promotionFlowIdsMap; 
    public static Map<Id,Deployment_Flow__c>promotionFlowsMap;
    private static Map<Id,Set<Step__c>> stepsPerDeployment = new Map<Id,Set<Step__c>>();
    private static Set<Step__c> stepsToUpdate = new Set<Step__c>();
    private static Boolean promotionsUpdated {get;set;}
    
    public static void prepareData(){
        System.debug('### Deployment prepareData');
        Set<Id> promotionIds = new Set<Id>();
        promotionDeploymentIdsMap = new Map<Id,Id>(); // Promotion__c.Id, Deployment__c.Id
        deploymentPromotionsMap = new Map<Id,Promotion__c>(); // Deployment__c.Id, Promotion__c
        promotionFlowIdsMap = new Map<Id,Id>(); // Promotion__c.Id, Deployment_Flow__c.Id
        promotionFlowsMap = new Map<Id,Deployment_Flow__c>(); // Deployment_Flow__c.Id, Deployment_Flow__c

        if(Trigger.new != null){
            for(SObject so:Trigger.new){
                Deployment__c d = (Deployment__c)so;
                if(d.Promotion__c != null) {
                    promotionIds.add(d.Promotion__c);
                    promotionDeploymentIdsMap.put(d.Promotion__c,d.Id);
                }
                if(d.Build_Task__c !=null)taskMap.put(d.Build_Task__c,null);
                if(d.From_Org__c !=null)orgMap.put(d.From_Org__c,null);
            }
            
            for(Promotion__c p : [SELECT Release__r.Project__r.Deployment_Flow__c, Project__r.Deployment_Flow__c, Status__c FROM Promotion__c WHERE Id IN :promotionIds]) {
                if(p.Release__r.Project__r.Deployment_Flow__c != null)promotionFlowIdsMap.put(p.Id,p.Release__r.Project__r.Deployment_Flow__c);
                if(p.Project__r.Deployment_Flow__c != null)promotionFlowIdsMap.put(p.Id,p.Project__r.Deployment_Flow__c);
                if(p.Project__r.Deployment_Flow__c != null || p.Release__r.Project__r.Deployment_Flow__c != null)deploymentPromotionsMap.put(promotionDeploymentIdsMap.get(p.Id),p);
            }
            
            for(Deployment_Flow__c df : [SELECT Active__c, Git_Repository__c, Main_Branch__c FROM Deployment_Flow__c WHERE Id IN :promotionFlowIdsMap.values()]) {
                if(df != null)promotionFlowsMap.put(df.Id,df);
            }     
        }
        
        if(Trigger.old != null){
            //For re-run deployments, we need to reset the manual step notifications
            for (Step__c step: [SELECT Id, Manual_Task_Notified__c, Deployment__c FROM Step__c WHERE Deployment__c IN :Trigger.old]) {
                if (stepsPerDeployment.containsKey(step.Deployment__c)) {
                    Set<Step__c> steps = stepsPerDeployment.get(step.Deployment__c);
                    steps.add(step);
                    stepsPerDeployment.put(step.Deployment__c, steps);
                } else {
                    Set<Step__c> steps = new Set<Step__c>();
                    steps.add(step);
                    stepsPerDeployment.put(step.Deployment__c, steps);
                }
            }

            for(SObject so:Trigger.old){
                Deployment__c d = (Deployment__c)so;
                if(d.From_Org__c !=null)orgMap.put(d.From_Org__c,null);
            }
        }
        
        for(Build_Task__c bt:[select Id, Continuous_Integration__r.Post_Success_Deployment_Jobs__c, Continuous_Integration__r.Post_Failed_Deployment_Jobs__c from Build_Task__c where Id in:taskMap.keySet()]){
            taskMap.put(bt.id, bt);
        }
        for(Org__c org:[select Id, Name, Environment__r.Org_ID__c from Org__c where Id in:orgMap.keySet()]){
            orgMap.put(org.id, org);
        }
    }
    public static void canDeployThis(Deployment__c d) {
        if(LicenseHelper.isLicensesExceeded())d.addError(Label.LICENSES_EXCEEDED);
        if(d.Promotion__c != null && (LicenseHelper.isCopadoEnabled() || LicenseHelper.isCCMEnabled())) {
            Boolean isActiveFlow = false;
            Boolean isCCMFlow = false;
            Boolean isValidCBMFlow = false;
            if(promotionFlowsMap.get(promotionFlowIdsMap.get(d.Promotion__c)) != null && promotionFlowsMap.get(promotionFlowIdsMap.get(d.Promotion__c)).Active__c)isActiveFlow = true;   
            
            if(isActiveFlow) {
                Deployment_Flow__c df = promotionFlowsMap.get(promotionFlowIdsMap.get(d.Promotion__c));
                if(df.Git_Repository__c == null && df.Main_Branch__c == null)isCCMFlow = true;
                else if(df.Git_Repository__c != null && df.Main_Branch__c != null)isValidCBMFlow = true;
                
                if(LicenseHelper.isCopadoEnabled() && !isCCMFlow && !isValidCBMFLow)d.addError(Label.CBM_FLOW_INVALID);
                if(!LicenseHelper.isCopadoEnabled() && isCCMFlow)d.addError(Label.CBM_FLOW_INVALID);
            } else d.addError(Label.PROMOTION_FLOW_INACTIVE);
        } else if(!LicenseHelper.isCopadoEnabled())d.addError(Label.COPADO_DEPLOYER_LICENSE_NOT_ENABLED);
    }
    public static void getValidateOnlyDeployments(Set<Id> ids){
        for(Step__c s:[select Deployment__c from Step__c where CheckOnly__c = true and Deployment__c in :ids]){
            // add deployment ids with check only steps, to prevent the promotion of all users stories upon vaildations
            checkOnly.add(s.Deployment__c);
        }
    }
    public static void checkPromotionCompleteness(Deployment__c oldd, Deployment__c newd){
        System.debug('### checkPromotionCompleteness');
        Promotion__c promotion = deploymentPromotionsMap.get(newd.Id);
        if(promotion != null) {
            String promotionStatus = promotion.Status__c;
            if(!checkOnly.contains(newd.Id) && !String.isBlank(newd.Promotion__c) && oldd.Status__c != 'Completed Successfully' && newd.Status__c=='Completed Successfully'){
                promotion.Status__c = 'Completed';
            } else if(!checkOnly.contains(newd.Id) && !String.isBlank(newd.Promotion__c) && oldd.Status__c != 'Completed with Errors' && newd.Status__c=='Completed with Errors'){
                promotion.Status__c = 'Completed with errors'; 
            } else if(checkOnly.contains(newd.Id) && !String.isBlank(newd.Promotion__c) && oldd.Status__c != 'Completed Successfully' && newd.Status__c=='Completed Successfully'){
                promotion.Status__c = 'Validated'; 
            } else if(checkOnly.contains(newd.Id) && !String.isBlank(newd.Promotion__c) && oldd.Status__c != 'Completed with Errors' && newd.Status__c=='Completed with Errors'){
                promotion.Status__c = 'Validation failed'; 
            } else if(!String.isBlank(newd.Promotion__c) && oldd.Status__c != 'In progress' && newd.Status__c=='In progress'){
                promotion.Status__c = 'In Progress'; 
            }
            System.debug('### promotionStatus: '+promotion.Status__c);
            if(promotionStatus != promotion.Status__c) {
                promosToComplete.add(promotion);
            }
        }
    }
    public static void checkBuildTaskCompleteness(Deployment__c oldd, Deployment__c newd){
        system.debug('### THIS DEPLOYMENT: '+ newd);
        if (!String.isBlank(newd.Build_Task__c)){
            system.debug('### THIS DEPLOYMENT HAS BUILD TASK: '+ newd.Build_Task__c);
            if(oldd.Status__c!='Completed Successfully' && newd.Status__c=='Completed Successfully' && taskMap.get(newd.Build_Task__c).Continuous_Integration__r.Post_Success_Deployment_Jobs__c==null ){
                system.debug('### CREATING BUILD TASK FOR SUCCESS: '+ newd.Build_Task__c);
                Build_Task__c ci = new Build_Task__c();
                ci.Id = newd.Build_Task__c;
                ci.Status__c = 'Success';
                bts.add(ci);
            }
            if(oldd.Status__c!='Completed with Errors' && newd.Status__c=='Completed with Errors' && taskMap.get(newd.Build_Task__c).Continuous_Integration__r.Post_Failed_Deployment_Jobs__c ==null){
                system.debug('### CREATING BUILD TASK FOR FAILED: '+ newd.Build_Task__c);
                Build_Task__c ci = new Build_Task__c();
                ci.Id = newd.Build_Task__c;
                ci.Status__c = 'Failed';
                bts.add(ci);
            }
        }
    }
    public static void updateBuildTasks(){
        system.debug('### Updating build tasks for Deployment Trigger: '+bts);
        Utilities.Secure_DML(bts, Utilities.DML_Action.UPD, schema.Sobjecttype.Build_Task__c);
    }
    public static void completePromotions(){
        System.debug('### completePromotions');
        if(promotionsUpdated == null) {
            promotionsUpdated = false;
        }
        if(!promotionsUpdated && promosToComplete.size() > 0) {
            System.debug('### promotionsUpdated');
            promotionsUpdated = true;
            Utilities.Secure_DML(promosToComplete, Utilities.DML_Action.UPD, schema.Sobjecttype.Promotion__c);
        }
    }
    public static void addHistory(Deployment__c d, String event){
        history.add(new Deployment_History__c(Deployment_Id__c = d.Id, Deployment__c = ( event=='Deleted'?null:d.Id),Date__c= System.now(), Event__c=event, Object__c='Deployment', User__c=UserInfo.getUserId()));
    }
    public static void addHistory(Deployment__c oldd, Deployment__c newd){
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Deployment__c.fields.getMap();
        for(String field:fieldMap.keyset()){
            DescribeFieldResult dfr = fieldMap.get(field).getDescribe();
            if(dfr.isUpdateable()){
                if(oldd.get(field) != newd.get(field)){
                    Deployment_History__c h = new Deployment_History__c(Deployment__c = oldd.Id,
                                                          Deployment_Id__c = oldd.Id,
                                                          Date__c= System.now(), 
                                                          Event__c='Updated', 
                                                          Object__c='Deployment', 
                                                          Field__c=dfr.getLabel(), 
                                                          User__c=UserInfo.getUserId(),
                                                          New_Value__c = (newd.get(field)!=null?String.valueOf(newd.get(field)):null),
                                                          Old_Value__c = (oldd.get(field)!=null?String.valueOf(oldd.get(field)):null)
                                                         );
                    if(String.isNotBlank(h.New_Value__c) && orgMap.containsKey(h.New_Value__c))h.New_Value__c = orgMap.get(h.New_Value__c).Name +' ('+ orgMap.get(h.New_Value__c).Environment__r.Org_ID__c +')';
                    if(String.isNotBlank(h.Old_Value__c) && orgMap.containsKey(h.Old_Value__c))h.Old_Value__c = orgMap.get(h.Old_Value__c).Name +' ('+ orgMap.get(h.Old_Value__c).Environment__r.Org_ID__c +')';
                    history.add(h);            
                }
            }
        }
        
    }
    public static void insertHistory(){
        Utilities.Secure_DML(history, Utilities.DML_Action.INS, schema.Sobjecttype.Deployment_History__c);
        history.clear();
    }
    public static void cleanManualTaskNotifications(Deployment__c oldDeployment, Deployment__c newDeployment) {
        //When a deployment starts...
        if (oldDeployment.Status__c != 'In Progress' && newDeployment.Status__c == 'In Progress') {
            if (stepsPerDeployment.containsKey(oldDeployment.Id)) {
                stepsToUpdate.addAll(stepsPerDeployment.get(oldDeployment.Id));
            }
        }
    }
    public static void updateSteps() {
        for (Step__c step: stepsToUpdate) {
            step.Manual_Task_Notified__c = false;
        }
        update new List<Step__c>(stepsToUpdate);
    }
}