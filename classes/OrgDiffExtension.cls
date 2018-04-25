public with sharing class OrgDiffExtension {
    public string diff_url{get;set;}
    public string deploy_url{get;set;}
    private OrgDiff__c orgdiff;
    public boolean withCreate{get;set;}
    public boolean withUpdate{get;set;}
    public boolean withDelete{get;set;}
    public String errorLevel {get; set;}
    public String messageName {get; set;}
    public boolean isShareable{get;set;}
    public Boolean showError {get;set;} 
    public Boolean showOptions {get;set;}

    public void showMessage() {
        ApexPages.Severity level = ApexPages.Severity.ERROR;
        if(errorLevel == 'WARNING') {
            level = ApexPages.Severity.Warning;
        }else{
            if(errorLevel == 'CONFIRM') {
                level = ApexPages.Severity.CONFIRM;
            }
        }
        ApexPages.addMessage(new ApexPages.Message(level, messageName));
        
    }
    
    public OrgDiffExtension(ApexPages.StandardController stdController) {
        // Add ALL the fields of the sobject to the list of queried fields, to avoid " SObject row was retrieved via SOQL without querying..."
        if (!Test.isRunningTest()) {
            stdController.addFields(new List<String>(Schema.SObjectType.OrgDiff__c.fields.getMap().keySet()));
        }
        showOptions = true;
        showError = false;
        orgdiff = (OrgDiff__c) stdController.getRecord();
        setUrls();
        Map<String, Schema.SObjectType> tokens = Schema.getGlobalDescribe();
		isShareable = tokens.containsKey('OrgDiff__Share');
        isLicenseEnabled();
    }

    public void setUrls(){
        //TODO: move this to external util method in order to use it in other classes 
        String urlParameters = '?nosid=1';
        String herokuServer = settings.Server_URL;
        String urlBase = herokuServer + '/json/v1/'; 
        diff_url = urlBase + 'diff/'+EncodingUtil.urlEncode(orgdiff.Id,'UTF-8') + urlParameters;
        if(orgdiff.Metadata_Types__c != null && orgdiff.Metadata_Types__c !='')diff_url += '&filter='+EncodingUtil.urlEncode(orgdiff.Metadata_Types__c,'UTF-8');
        
        withCreate = ApexPages.currentPage().getParameters().get('withCreate')+''=='true';
        withUpdate = ApexPages.currentPage().getParameters().get('withUpdate')+''=='true';
        withDelete = ApexPages.currentPage().getParameters().get('withDelete')+''=='true';
        deploy_url = urlBase + 'diffDeployment/'+EncodingUtil.urlEncode(orgdiff.Id,'UTF-8')+urlParameters+'&withCreate='+withCreate+'&withUpdate='+withUpdate+'&withDelete='+withDelete;
    }
    public PageReference validateOrgs(){
        if(!DeployAPI.validateOrg(orgdiff.From_Org__c)){
            Apexpages.addMessage(new apexpages.Message(apexpages.severity.error,Schema.OrgDiff__c.fields.From_Org__c.getDescribe().getLabel()+': '+Label.WRONG_CREDENTIALS));
        }
        if(!DeployAPI.validateOrg(orgdiff.To_Org__c)){
            Apexpages.addMessage(new apexpages.Message(apexpages.severity.error,Schema.OrgDiff__c.fields.To_Org__c.getDescribe().getLabel()+': '+Label.WRONG_CREDENTIALS));
        }
        return null;
    }
    public PageReference deploy(){
        if(LicenseHelper.isLicensesExceeded()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,Label.LICENSES_EXCEEDED));
            return null;
        }
        if(!withCreate && !withUpdate && !withDelete){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,Label.SELECT_AT_LEAST_ONE_RECORD));
            return null;
        }
        if(!DeployAPI.validateOrg(orgdiff.From_Org__c)){
            Apexpages.addMessage(new apexpages.Message(apexpages.severity.error,Schema.OrgDiff__c.fields.From_Org__c.getDescribe().getLabel()+': '+Label.WRONG_CREDENTIALS));
            return null;
        }
        if(!DeployAPI.validateOrg(orgdiff.To_Org__c)){
            Apexpages.addMessage(new apexpages.Message(apexpages.severity.error,Schema.OrgDiff__c.fields.To_Org__c.getDescribe().getLabel()+': '+Label.WRONG_CREDENTIALS));
            return null;
        }
        PageReference pr = Page.OrgDiffDeployment;
        pr.setRedirect(true);
        pr.getParameters().put('Id',orgdiff.Id);
        pr.getParameters().put('withCreate',withCreate+'');
        pr.getParameters().put('withUpdate',withUpdate+'');
        pr.getParameters().put('withDelete',withDelete+'');
        return pr;
    }
        public void isLicenseEnabled(){
        if (!LicenseHelper.actionIsLicenseEnabled('viewEditOrgDifferences')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.CAD_License_Restriction));
            showError = true;
            showOptions = false;
        }
        return;
    }
}