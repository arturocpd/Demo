@isTest
private class TestDeploymentTrigger {
	@testSetup static void setupData() {
		TestUtilities.getAllMultilicense();
	}
	@testSetup
	static void setupDataDML() {
		testMethodUtilities.upsertOrgwideSettings();
		TestUtilities.assignLicense(UserInfo.getUserName(), true, false, true);
	}
	static testMethod void testBuildTaskUpdate() {
		Continuous_Integration__c ci1 = new Continuous_Integration__c(Name='My CI 1', Active__c=true, Status__c='Draft');
		Continuous_Integration__c ci2 = new Continuous_Integration__c(Name='My CI 2', Active__c=true, Status__c='Draft');
		List<Continuous_Integration__c> cis = new List<Continuous_Integration__c>();
		cis.add(ci1);
		cis.add(ci2);
		insert cis;

		List<Build_Task__c> bts = new List<Build_Task__c>();
		bts.add(new Build_Task__c(Continuous_Integration__c=ci1.Id, Duration__c=1, Status__c='Pending'));
		bts.add(new Build_Task__c(Continuous_Integration__c=ci2.Id, Duration__c=2, Status__c='Pending'));
		insert bts;
	
		Org__c testFromOrg = testMethodUtilities.create('OrgName','Production','PASSWORD','SFDC_OrgId','SFDC_TOKEN','USERNAME', System.now());
		insert testFromOrg;

		Deployment__c testDeployment1 = testMethodUtilities.create('DEPLOYMENT_NAME',System.now(), System.now(),testFromOrg.Id,'Deploy now','Scheduled');
		Deployment__c testDeployment2 = testMethodUtilities.create('DEPLOYMENT_NAME',System.now(), System.now(),testFromOrg.Id,'Deploy now','Scheduled');
		testDeployment1.Build_Task__c = bts[0].Id;
		testDeployment2.Build_Task__c = bts[1].Id;
		insert testDeployment1;
		insert testDeployment2;
		List<Deployment__c> deployments = new List<Deployment__c>();
		testDeployment1.Status__c = 'Completed Successfully';
		testDeployment2.Status__c = 'Completed with Errors';
		deployments.add(testDeployment1);
		deployments.add(testDeployment2);
		system.debug('### Updating deployments: '+deployments);
		update deployments;

		List<Build_Task__c> results = [SELECT Id, Continuous_Integration__c, Status__c FROM Build_Task__c WHERE Continuous_Integration__c=:cis[0].Id or Continuous_Integration__c=:cis[1].Id];
		system.debug('### RESULTING BUILD TASKS: '+results);
		for(Build_Task__c r : results){
			if(r.Continuous_Integration__c==cis[0].Id)system.assertEquals('Success', r.Status__c);
			if(r.Continuous_Integration__c==cis[1].Id)system.assertEquals('Failed', r.Status__c);
		}
	}
    static testMethod void testDeploymentHistory() {
        Org__c testFromOrg = testMethodUtilities.create('OrgName','Production','PASSWORD','SFDC_OrgId','SFDC_TOKEN','USERNAME', System.now());
		insert testFromOrg;
        
        Org__c testFromOrg2 = testMethodUtilities.create('OrgName2','Production','PASSWORD2','SFDC_OrgId2','SFDC_TOKEN2','USERNAME2', System.now());
		insert testFromOrg2;

		Deployment__c testDeployment1 = testMethodUtilities.create('DEPLOYMENT_NAME',System.now(), System.now(),testFromOrg.Id,'Deploy now','Scheduled');
        insert testDeployment1;
        
        System.assertNotEquals(0, [SELECT count() FROM Deployment_History__c WHERE Deployment__c = :testDeployment1.Id AND Deployment_Id__c = :testDeployment1.id AND Event__c='Created' AND Object__c='Deployment']);
        
        testDeployment1.From_Org__c = testFromOrg2.Id;
        testDeployment1.Name = 'changed x';
        testDeployment1.Status__c  ='In progress';
        testDeployment1.Date__c = System.now();
        update testDeployment1;
        
        System.assertNotEquals(0, [SELECT count() FROM Deployment_History__c WHERE Deployment__c = :testDeployment1.Id AND Deployment_Id__c = :testDeployment1.id AND Event__c='Updated' AND Object__c='Deployment' AND Field__c='Deployment Name']);
        
        testDeployment1.From_Org__c = null;
        update testDeployment1;
        
        Destination_Org__c dorg = new Destination_Org__c(Deployment__c = testDeployment1.Id, To_Org__c = testFromOrg.Id);
        insert dorg;
        delete dorg;

        delete testDeployment1;

        System.assertNotEquals(0, [SELECT count() FROM Deployment_History__c WHERE Deployment_Id__c = :testDeployment1.id AND Event__c='Deleted' AND Object__c='Deployment']);
    }
	static testMethod void testCompletePromotions() {
		Feature__c feature = new Feature__c(Name='Branch Management', Enabled__c=true, Quantity__c=10);
		insert feature;

		Git_Repository__c gitRepo = new Git_Repository__c(name = 'gitRepo');
		insert gitRepo;
		Deployment_Flow__c flowCBM = CMTestMethodUtilities.createCBMFlow('CBM flow', true, gitRepo.Id, 'master');
		insert flowCBM;
		System.assert(flowCBM.Id != null);

		Project__c testProject = CMTestMethodUtilities.createProject('test project');
		testProject.Deployment_Flow__c = flowCBM.Id;
		insert testProject;

		String b = '{"customerOrg":{"Name":"Copado Ltd","orgId":"00Db0000000KFgoEAG","autoRecharge":true,"credits":425,"id":995},"userInfo":{"accessibilityMode__is_set":true,"accessibilityMode":false,"currencySymbol__is_set":true,"currencySymbol":"€","orgAttachmentFileSizeLimit__is_set":true,"orgAttachmentFileSizeLimit":5242880,"orgDefaultCurrencyIsoCode__is_set":true,"orgDefaultCurrencyIsoCode":"EUR","orgDisallowHtmlAttachments__is_set":true,"orgDisallowHtmlAttachments":false,"orgHasPersonAccounts__is_set":true,"orgHasPersonAccounts":false,"organizationId__is_set":true,"organizationId":"00Db0000000KFgoEAG","organizationMultiCurrency__is_set":true,"organizationMultiCurrency":false,"organizationName__is_set":true,"organizationName":"Copado Ltd","profileId__is_set":true,"profileId":"00eb0000000mWB2AAM","roleId__is_set":true,"sessionSecondsValid__is_set":true,"sessionSecondsValid":7200,"userDefaultCurrencyIsoCode__is_set":true,"userEmail__is_set":true,"userEmail":"pr@copa.do","userFullName__is_set":true,"userFullName":"Philipp Rackwitz","userId__is_set":true,"userId":"005b0000000hMqqAAE","userLanguage__is_set":true,"userLanguage":"en_US","userLocale__is_set":true,"userLocale":"en_GB","userName__is_set":true,"userName":"pr@copa.do.basepackage","userTimeZone__is_set":true,"userTimeZone":"Europe/Paris","userType__is_set":true,"userType":"Standard","userUiSkin__is_set":true,"userUiSkin":"Theme3"}}';
		Test.setMock(HttpCalloutMock.class, new testHttpCalloutMock(b, null));

		Environment__c env1 = new Environment__c(Name='Dev1 Environment',Type__c='Sandbox');
		insert env1;
		Environment__c env2 = new Environment__c(Name='Integration Environment',Type__c='Production');
		insert env2;
		Org__c testOrg1 = CMTestMethodUtilities.createOrg('Dev1', 'Sandbox', null, 'SFDC_OrgId', null, null, System.now(), env1.Id);
		insert testOrg1;
		Org__c testOrg2 = CMTestMethodUtilities.createOrg('Integration', 'Production', null, 'SFDC_OrgId2', null, null, System.now(), env2.Id);
		insert testOrg2;

		Deployment_Flow_Step__c dfs = CMTestMethodUtilities.createFlowStep(env1.Id, env2.Id, flowCBM.Id);
		dfs.Branch__c = 'dev1';
		insert dfs;

		Promotion__c promotion1 = new Promotion__c(Source_Environment__c = env1.Id, Project__c = testProject.Id);
		insert promotion1;

		User_Story__c userStory = new User_Story__c(User_Story_Title__c = 'US1', Environment__c = env1.Id, Org_Credential__c = testOrg1.Id, Project__c = testProject.Id, Promote_and_Deploy__c = true);
		insert userStory;

		Promoted_User_Story__c pus = new Promoted_User_Story__c();
		pus.User_Story__c = userStory.Id;
		pus.Promotion__c = promotion1.Id;
		insert pus;

		Test.startTest();
		Deployment__c deployment = testMethodUtilities.create('DEPLOYMENT_NAME', System.now(), System.now(), testOrg1.Id, 'Deploy now', 'In progress');
		deployment.Promotion__c = promotion1.Id;
		insert deployment;

		Destination_Org__c destinationOrg1 = testMethodUtilities.create(deployment.id, 'Pending', testOrg1.Id);
		insert destinationOrg1;
		Step__c step1 = testMethodUtilities.create('Step 1', 'attId', 'JSONString', deployment.Id, 1, 'Pending', 'MetaData');
		insert step1;

        System.debug('### Update Deployment Job to Success');
		Deployment_Job__c deploymentJob1 = [SELECT Id, Status__c FROM Deployment_Job__c WHERE Step__c = :step1.Id AND destination_org__c = :destinationOrg1.Id];
		System.assertEquals('Pending', deploymentJob1.Status__c);
		deploymentJob1.Status__c = 'Success';
		deploymentJob1.Deployed__c = 100;
		update deploymentJob1;

        // Verify that the Step and the Deployment are Completed Successfully
		System.assertEquals('Completed Successfully', [SELECT Status__c FROM Step__c WHERE Id = :step1.Id].Status__c);
		System.assertEquals('Completed Successfully', [SELECT Status__c FROM Deployment__c WHERE Id = :deployment.Id].Status__c);

        // Verify that the Promotion is Completed Successfully and the User Story Environment is the target environment
		System.assertEquals('Completed', [SELECT Status__c FROM Promotion__c WHERE Id = :promotion1.Id].Status__c);
		System.assertEquals(env2.Id, [SELECT Environment__c FROM User_Story__c WHERE Id = :userStory.Id].Environment__c);
		Test.stopTest();
	}
}