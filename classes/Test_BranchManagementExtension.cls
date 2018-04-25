@isTest
public with sharing class Test_BranchManagementExtension {
	@testSetup static void setupTestData(){
		TestUtilities.getAllMultilicense();
	}
	@testSetup static void setupTestDataDML(){
		testMethodUtilities.upsertOrgwideSettings();
		TestUtilities.assignLicense(UserInfo.getUserName(), true, true, true, true, true);

		List<Environment__c> environments = new List<Environment__c>();
		Environment__c env1 = CMTestMethodUtilities.createEnvironment('Dev1', 'SFDC_OrgId');
        env1.Type__c = 'Production/Developer';
		environments.add( env1 );
		Environment__c env2 = CMTestMethodUtilities.createEnvironment('Dev2', 'SFDC_OrgId2');
        env2.Type__c = 'Production/Developer';
		environments.add( env2 );
		Environment__c env3 = CMTestMethodUtilities.createEnvironment('Int', 'SFDC_OrgId3');
        env3.Type__c = 'Production/Developer';
		environments.add( env3 );
		Environment__c env4 = CMTestMethodUtilities.createEnvironment('UAT', 'SFDC_OrgId4');
        env4.Type__c = 'Production/Developer';
		environments.add( env4 );
		Environment__c env5 = CMTestMethodUtilities.createEnvironment('Prod', 'SFDC_OrgId5');
        env5.Type__c = 'Production/Developer';
		environments.add( env5 );
		insert environments;
		System.assertNotEquals(env1.Id, null);
		System.assertNotEquals(env2.Id, null);
		System.assertNotEquals(env3.Id, null);
		System.assertNotEquals(env4.Id, null);
		System.assertNotEquals(env5.Id, null);

		Org__c orgDev1 = CMTestMethodUtilities.createOrg('OrgDev1', 'Sandbox', null, 'SFDC_OrgId', null, null, system.now(), env1.Id);
		Org__c orgDev2 = CMTestMethodUtilities.createOrg('OrgDev2', 'Sandbox', null, 'SFDC_OrgId2', null, null, system.now(), env2.Id);
		Org__c orgInt = CMTestMethodUtilities.createOrg('OrgInt', 'Sandbox', null, 'SFDC_OrgId3', null, null, system.now(), env3.Id);
		Org__c orgProd = CMTestMethodUtilities.createOrg('OrgProd', 'Sandbox', null, 'SFDC_OrgId4', null, null, system.now(), env4.Id);
		insert new List<Org__c> {orgDev1, orgDev2, orgInt, orgProd};

		System.assertNotEquals(orgDev1.Id, null);
		System.assertNotEquals(orgDev2.Id, null);
		System.assertNotEquals(orgInt.Id, null);
		System.assertNotEquals(orgProd.Id, null);

		Feature__c feature = new Feature__c(Name = 'Branch Management', Enabled__c = true, Quantity__c = 10);
		insert feature;
		System.assertNotEquals(feature.Enabled__c, false);

		Git_Repository__c gitRepo = new Git_Repository__c(name = 'gitRepo');
		insert gitRepo;
		System.assertNotEquals(gitRepo.Id, null);

		Deployment_Flow__c flow = CMTestMethodUtilities.createCBMFlow('CBM flow', true, gitRepo.Id, 'master');
		insert flow;
		System.assertNotEquals(flow.Id, null);

		List<Deployment_Flow_Step__c> flowSteps = new List<Deployment_Flow_Step__c>();
		Deployment_Flow_Step__c dfs = CMTestMethodUtilities.createFlowStep(env1.Id, env3.Id, flow.Id);
		dfs.Branch__c = 'dev1';
		flowSteps.add( dfs );
		Deployment_Flow_Step__c dfs2 = CMTestMethodUtilities.createFlowStep(env2.Id, env3.Id, flow.Id);
		dfs2.Branch__c = 'dev2';
		flowSteps.add( dfs2 );
		Deployment_Flow_Step__c dfs3 = CMTestMethodUtilities.createFlowStep(env3.Id, env4.Id, flow.Id);
		dfs3.Branch__c = 'int';
		flowSteps.add( dfs3 );
		Deployment_Flow_Step__c dfs4 = CMTestMethodUtilities.createFlowStep(env4.Id, env5.Id, flow.Id);
		dfs4.Branch__c = 'prod';
		flowSteps.add( dfs4 );
		insert flowSteps;

		System.assertNotEquals(dfs.Id, null);
		System.assertNotEquals(dfs2.Id, null);
		System.assertNotEquals(dfs3.Id, null);
		System.assertNotEquals(dfs4.Id, null);

		Project__c testProject = CMTestMethodUtilities.createProject('My Project');
		testProject.Deployment_Flow__c = flow.Id;
		insert testProject;
		System.assertNotEquals(testProject.Id, null);
		System.assertEquals(testProject.Deployment_Flow__c, flow.Id);

		Git_Backup__c gitSnapshotDev1 = new Git_Backup__c(Git_Repository__c = gitRepo.id, Org__c = orgDev1.id, Branch__c = 'dev1');
		Git_Backup__c gitSnapshotDev2 = new Git_Backup__c(Git_Repository__c = gitRepo.id, Org__c = orgDev2.id, Branch__c = 'dev2');
		Git_Backup__c gitSnapshotInt = new Git_Backup__c(Git_Repository__c = gitRepo.id, Org__c = orgInt.id, Branch__c = 'int');
		Git_Backup__c gitSnapshotProd = new Git_Backup__c(Git_Repository__c = gitRepo.id, Org__c = orgProd.id, Branch__c = 'master');
		insert new List<Git_Backup__c> {gitSnapshotDev1, gitSnapshotDev2, gitSnapshotInt, gitSnapshotProd};

		System.assertNotEquals(gitSnapshotDev1.Id, null);
		System.assertNotEquals(gitSnapshotDev2.Id, null);
		System.assertNotEquals(gitSnapshotInt.Id, null);
		System.assertNotEquals(gitSnapshotProd.Id, null);

		Git_Org_Commit__c snapshotCommit1 = new Git_Org_Commit__c(Git_Backup__c = gitSnapshotDev1.id, Org__c = orgDev1.id, Commit_Id__c = 'b7adccf3937495e8928d1023c5a5c644198b8974', Commit_Date__c = Date.today().addDays(-3), Commit_Message__c = 'test 1', Status__c = 'Complete'
		                                                         );
		Git_Org_Commit__c snapshotCommit2 = new Git_Org_Commit__c(Git_Backup__c = gitSnapshotDev2.id, Org__c = orgDev2.id, Commit_Id__c = 'b8adccf3937495e8928d1023c5a5c644198b1234', Commit_Date__c = Date.today().addDays(-2), Commit_Message__c = 'test 2', Status__c = 'Complete'
		                                                         );
		Git_Org_Commit__c snapshotCommit3 = new Git_Org_Commit__c(Git_Backup__c = gitSnapshotDev1.id, Org__c = orgDev1.id, Commit_Id__c = 'b9adccf3937495e8928d1023c5a5c644198b9876', Commit_Date__c = Date.today().addDays(-1), Commit_Message__c = 'test 3', Status__c = 'Complete'
		                                                         );
		insert new List<Git_Org_Commit__c> {snapshotCommit1, snapshotCommit2, snapshotCommit3};

		System.assertNotEquals(snapshotCommit1.Id, null);
		System.assertNotEquals(snapshotCommit2.Id, null);
		System.assertNotEquals(snapshotCommit3.Id, null);
	}
	@isTest static void mergeStep() {

		Map<String, String> d = GlobalUtilities.getAllFieldsWithoutSharing('Deployment_Flow__c');
		String soqlString = 'SELECT ' + d.get(Label.FIELDS) + ' FROM ' + d.get(Label.OBJECT) + ' LIMIT 1';
		Deployment_Flow__c flow = Database.query(soqlString);

		d = GlobalUtilities.getAllFieldsWithoutSharing('Deployment_Flow_Step__c');
		soqlString = 'SELECT ' + d.get(Label.FIELDS) + ' FROM ' + d.get(Label.OBJECT) + ' WHERE Deployment_Flow__c =\'' + flow.Id + '\'';
		List<Deployment_Flow_Step__c> steps = Database.query(soqlString);
		System.debug(loggingLevel.Error, '*** steps: ' + steps);

		Deployment_Flow_Step__c testStep = steps[0];
		System.debug(loggingLevel.Error, '*** testStep: ' + testStep);

		Project__c project = [SELECT Id FROM Project__c LIMIT 1];

		Org__c org = [Select Id, Environment__c FROM Org__c WHERE Name = 'OrgDev1'];
		Org__c orgInt = [Select Id, Environment__c FROM Org__c WHERE Name = 'OrgInt'];

		Release__c release = CMTestMethodUtilities.createRelease('Release1');
		release.Project__c = project.Id;
		insert release;
		System.assertNotEquals(release.Id, null);

		String flowResult = '[{"pullMergeResult":"MERGED","sourceBranch":"dev2","pullCompareCommits":"1d4e7459c2a53e0bdbc2267178dc6de469f41c27_vs_59d2898f7d338eec1fd1ab377bb61ef75387f010","pullCompareBranches":"uat_vs_dev2","filesMergedBehind":[{"d":"update","f":"objects/Contact.object"},{"d":"update","f":"objects/Account.object"}],"mergeTimestamp":"1500564866000","commitsBehind":6,"filesMergedConflictBehind":[],"commitsAhead":0,"pullDestinationCommit":"59d2898f7d338eec1fd1ab377bb61ef75387f010","pullSuccess":true,"filesMergedConflictAhead":[],"id":"a090Y000003NG0vQAG","pullSourceCommit":"1d4e7459c2a53e0bdbc2267178dc6de469f41c27","pullDone":true,"destinationBranch":"uat"},{"mergeCompareCommits":"fd928c33d8e0c175e45ae7cd8fc827e27be5abe7_vs_1d4e7459c2a53e0bdbc2267178dc6de469f41c27","pullMergeResult":"MERGED","sourceBranch":"dev1","pullCompareCommits":"1d4e7459c2a53e0bdbc2267178dc6de469f41c27_vs_fd928c33d8e0c175e45ae7cd8fc827e27be5abe7","mergeMergeResult":"MERGED","pullCompareBranches":"uat_vs_dev1","filesMergedBehind":[{"d":"update","f":"objects/Account.object"}],"mergeDone":true,"mergeTimestamp":"1503469473000","commitsBehind":1,"filesMergedConflictBehind":[],"commitsAhead":1,"pullDestinationCommit":"fd928c33d8e0c175e45ae7cd8fc827e27be5abe7","mergeDestinationCommit":"1d4e7459c2a53e0bdbc2267178dc6de469f41c27","mergeSuccess":true,"pullSuccess":true,"mergeCompareBranches":"dev1_vs_uat","mergeSourceCommit":"fd928c33d8e0c175e45ae7cd8fc827e27be5abe7","filesMergedConflictAhead":[],"id":"' + testStep.Id + '","pullSourceCommit":"1d4e7459c2a53e0bdbc2267178dc6de469f41c27","pullDone":true,"destinationBranch":"uat","filesMergedAhead":[{"d":"update","f":"objects/Account.object"},{"d":"update","f":"classes/IntegerConverter.cls"},{"d":"update","f":"classes/AccountOperations.cls"}]},{"mergeCompareCommits":"1d4e7459c2a53e0bdbc2267178dc6de469f41c27_vs_b6145d243f54736729456f0dd262a39ab8894f4d","sourceBranch":"uat","mergeMergeResult":"MERGED","mergeDone":true,"mergeTimestamp":"1501490921000","commitsBehind":0,"filesMergedConflictBehind":[],"commitsAhead":2,"mergeDestinationCommit":"b6145d243f54736729456f0dd262a39ab8894f4d","mergeSuccess":true,"mergeCompareBranches":"uat_vs_master","mergeSourceCommit":"1d4e7459c2a53e0bdbc2267178dc6de469f41c27","filesMergedConflictAhead":[],"id":"a090Y000003NG15QAG","destinationBranch":"master","filesMergedAhead":[{"d":"update","f":"objects/Contact.object"},{"d":"update","f":"workflows/Account.workflow"},{"d":"update","f":"objects/Account.object"}]}]';
		String stepResult = '{"mergeValidationDone":true,"pullValidationSuccess":false,"pullValidationDone":true,"mergeValidationStatus":"Completed","pullValidationErrors":[{"l":"ERROR","m":"Test failure, method: FieldMappingController_Test.test_method_one -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c]: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c] stack Class.FieldMappingController_Test.test_method_one: line 11, column 1","t":""},{"l":"ERROR","m":"Test failure, method: FieldMappingController_Test.test_method_two -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c]: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c] stack Class.FieldMappingController_Test.test_method_two: line 157, column 1","t":""},{"l":"ERROR","m":"Test failure, method: Test_RestIntegrationHandler.asyncSuccessfulCreate -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c]: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c] stack Class.Test_RestIntegrationHandler.asyncSuccessfulCreate: line 278, column 1","t":""},{"l":"ERROR","m":"Test failure, method: AccountOperationsTest.testAccountHasDefaultDescription -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c]: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c] stack Class.AccountOperationsTest.testAccountHasDefaultDescription: line 7, column 1","t":""},{"l":"ERROR","m":"Test failure, method: Test_RestIntegrationHandler.successfulCreateStdControl -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c]: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c] stack Class.Test_RestIntegrationHandler.successfulCreateStdControl: line 157, column 1","t":""},{"l":"ERROR","m":"Test failure, method: Test_RestIntegrationHandler.successfulCreate -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c]: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c] stack Class.Test_RestIntegrationHandler.successfulCreate: line 41, column 1","t":""},{"l":"ERROR","m":"Test failure, method: Test_RestIntegrationHandler.typeConversion -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c]: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c] stack Class.Test_RestIntegrationHandler.typeConversion: line 439, column 1","t":""},{"l":"ERROR","m":"Code coverage issue:  -- Average test coverage across all Apex Classes and Triggers is 27%, at least 75% test coverage is required.","t":""}],"id":"' + testStep.Id + '","pullValidationStatus":"Completed","mergeValidationSuccess":false,"mergeValidationErrors":[{"l":"ERROR","m":"Test failure, method: FieldMappingController_Test.test_method_two -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c]: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c] stack Class.FieldMappingController_Test.test_method_two: line 157, column 1","t":""},{"l":"ERROR","m":"Test failure, method: FieldMappingController_Test.test_method_one -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c]: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c] stack Class.FieldMappingController_Test.test_method_one: line 11, column 1","t":""},{"l":"ERROR","m":"Test failure, method: AccountOperationsTest.testAccountHasDefaultDescription -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c]: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c] stack Class.AccountOperationsTest.testAccountHasDefaultDescription: line 7, column 1","t":""},{"l":"ERROR","m":"Test failure, method: Test_RestIntegrationHandler.successfulCreate -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c]: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c] stack Class.Test_RestIntegrationHandler.successfulCreate: line 41, column 1","t":""},{"l":"ERROR","m":"Test failure, method: Test_RestIntegrationHandler.successfulCreateStdControl -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c]: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c] stack Class.Test_RestIntegrationHandler.successfulCreateStdControl: line 157, column 1","t":""},{"l":"ERROR","m":"Test failure, method: Test_RestIntegrationHandler.typeConversion -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c]: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c] stack Class.Test_RestIntegrationHandler.typeConversion: line 439, column 1","t":""},{"l":"ERROR","m":"Test failure, method: Test_RestIntegrationHandler.asyncSuccessfulCreate -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c]: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c] stack Class.Test_RestIntegrationHandler.asyncSuccessfulCreate: line 278, column 1","t":""},{"l":"ERROR","m":"Code coverage issue:  -- Average test coverage across all Apex Classes and Triggers is 27%, at least 75% test coverage is required.","t":""}]}';
		List<User_Story__c> userStoryList = new List<User_Story__c>();
		User_Story__c userStory = CMTestMethodUtilities.createUserStory('MyStory1');
		userStory.Project__c = project.Id;
		userStory.Release__c = release.Id;
		userStory.Org_Credential__c = org.Id;
		userStory.Promote_Change__c = true;
		userStoryList.add(userStory);

		User_Story__c userStory2 = CMTestMethodUtilities.createUserStory('MyStory2');
		userStory2.Project__c = project.Id;
		userStory2.Release__c = release.Id;
		userStory2.Org_Credential__c = orgInt.Id;
		userStory2.Promote_Change__c = true;
		userStoryList.add(userStory2);

		User_Story__c userStory3 = CMTestMethodUtilities.createUserStory('MyStory3');
		userStory3.Project__c = project.Id;
		userStory3.Release__c = release.Id;
		userStory3.Org_Credential__c = org.Id;
		userStory3.Promote_Change__c = true;
		userStoryList.add(userStory3);

		User_Story__c userStory4 = CMTestMethodUtilities.createUserStory('MyStory4');
		userStory4.Project__c = project.Id;
		userStory4.Release__c = release.Id;
		userStory4.Org_Credential__c = orgInt.Id;
		userStory4.Promote_Change__c = true;
		userStoryList.add(userStory4);

		insert userStoryList;

		List<Promotion__c> promList = new List<Promotion__c>();
		Promotion__c prom = CMTestMethodUtilities.createPromotion(project.Id, org.Environment__c);
		prom.Destination_Environment__c = orgInt.Environment__c;
		prom.Status__c = 'Completed';
		promList.add(prom);
		Promotion__c prom2 = CMTestMethodUtilities.createPromotion(project.Id, orgInt.Environment__c);
		prom2.Destination_Environment__c = org.Environment__c;
		prom2.Status__c = 'Completed';
		promList.add(prom2);
		insert promList;

		List<Promoted_User_Story__c> pusList = new List<Promoted_User_Story__c>();
		Promoted_User_Story__c pus = new Promoted_User_Story__c(
		    User_Story__c = userStory2.id,
		    Promotion__c = prom.Id
		);
		pusList.add(pus);
		Promoted_User_Story__c pus2 = new Promoted_User_Story__c(
		    User_Story__c = userStory3.id,
		    Promotion__c = prom2.Id
		);
		pusList.add(pus2);
		insert pusList;

		d = GlobalUtilities.getAllFieldsWithoutSharing('Git_Org_Commit__c');
		soqlString = 'SELECT ' + d.get(Label.FIELDS) + ' FROM ' + d.get(Label.OBJECT) + ' LIMIT 10';
		List<Git_Org_Commit__c> orgCommits = Database.query(soqlString);

		List<User_Story_Commit__c> usCommits = new List<User_Story_Commit__c>();
		for (Git_Org_Commit__c gc : orgCommits) {
			User_Story_Commit__c userStoryCommit = new User_Story_Commit__c(User_Story__c = userStory.id, Snapshot_Commit__c = gc.id);
			User_Story_Commit__c userStoryCommit2 = new User_Story_Commit__c(User_Story__c = userStory2.id, Snapshot_Commit__c = gc.id);
			User_Story_Commit__c userStoryCommit3 = new User_Story_Commit__c(User_Story__c = userStory3.id, Snapshot_Commit__c = gc.id);
			User_Story_Commit__c userStoryCommit4 = new User_Story_Commit__c(User_Story__c = userStory4.id, Snapshot_Commit__c = gc.id);
			usCommits.add(userStoryCommit);
			usCommits.add(userStoryCommit2);
			usCommits.add(userStoryCommit3);
			usCommits.add(userStoryCommit4);
		}
		insert usCommits;

		Test.startTest();
		Test.setCurrentPage(new PageReference('BranchManagement.Page'));

		System.currentPageReference().getParameters().put('fromEnvId', testStep.Source_Environment__c);
		System.currentPageReference().getParameters().put('toEnvId', testStep.Destination_Environment__c);
		System.currentPageReference().getParameters().put('envId', testStep.Source_Environment__c);
		System.currentPageReference().getParameters().put('type', 'merge');
		System.currentPageReference().getParameters().put('stepId', testStep.Id);
		System.currentPageReference().getParameters().put('flowId', flow.Id);
		System.currentPageReference().getParameters().put('flowResult', flowResult);
		System.currentPageReference().getParameters().put('stepResult', stepResult);

		BranchManagementExtension ext = new BranchManagementExtension(new ApexPages.StandardController(flow));

		ext.resetModalsDOM();
		ext.showUserStories();
		System.assertEquals(ext.showUserStories, true);
		ext.showCommits();
		System.assertEquals(ext.showCommits, true);
		ext.showErrors();
		System.assertEquals(ext.showErrors, true);
		ext.showFileDifferences();
		System.assertEquals(ext.showFileDifferences, true);
		ext.showAutoResolves();
		System.assertEquals(ext.showAutoResolves, true);
		String keys = ext.jobsManagerMatchingKeys;
		System.assertNotEquals(keys, '');
		ext.prepareOverlay();
		ext.errorsOverlay();
		ext.userStoriesOverlay();
		System.assertNotEquals(null, ext.latestOverlay);
		System.assertEquals(0, ext.usPlaceHolder.size());

		ext.showUserStories();
		ext.showErrors();
		ext.showFileDifferences();
		ext.showAutoResolves();

		ext.promotion.Project__c = project.Id;
		ext.getPromotableUserStories();

		for (Integer i = 0; i < ext.latestOverlay.userStories.size(); i++) {
			ext.latestOverlay.userStories[i].isSelected = true;
		}

		ext.createPromotionAndDeploy();
		ext.toggleRebaseListView();
		ext.resetRebaseModal();
		ext.calculateUserStoryEnvironmentAvailability(new List<User_Story__c> {userStory});
		ext.prepareRebase();
		System.assertNotEquals(null, testStep.Destination_Environment__c);
		ext.rebaseSource = orgInt.Environment__c;
		System.assertEquals(testStep.Destination_Environment__c, ext.rebaseSource);
		ext.getRebaseUserStories();
		ext.rebaseProject = project.Id;
		ext.rebaseRelease = release.Id;
		ext.getRebaseUserStories();
		System.assertEquals(project.Id, ext.rebaseProject);
		System.assertEquals(release.Id, ext.rebaseRelease);
		ext.createRebasePromotionsAndDeploy();
		System.debug('ext.rebasePromotionsMap.keySet(): '+ext.rebasePromotionsMap.keySet());
		System.assertNotEquals(0,ext.rebasePromotionsMap.keySet().size());
		ext.goToPromotions();
		System.assertEquals(true,ext.rebasePromotionsCreated);
		System.assertEquals(false,ext.showHiddenCheckboxes);
		ext.getIsRebasePromotionsCreated();
		System.assertEquals(true,ext.rebasePromotionsCreated);
		ext.getEnabledRebasePromotionPoller();
		System.assertEquals(true,ext.enabledRebasePromotionPoller);
		ext.checkRebasePromotionsStatuses();
		ext.resetPromotions();
		System.assertEquals(1,ApexPages.getMessages().size());
		System.assertEquals(false,ext.rebasePromotionsCreated);
		System.assertEquals(false,ext.rebaseDeploymentsCompleted);
		System.assertEquals(false,ext.enabledRebasePromotionPoller);
		System.assertEquals(false,ext.showHiddenCheckboxes);
		
		System.currentPageReference().getParameters().put('message', 'Test page message');
		ext.addPageMessages();
		Test.stopTest();
	}
	@isTest static void pullStep() {

		Map<String, String> d = GlobalUtilities.getAllFieldsWithoutSharing('Deployment_Flow__c');
		String soqlString = 'SELECT ' + d.get(Label.FIELDS) + ' FROM ' + d.get(Label.OBJECT) + ' LIMIT 1';
		Deployment_Flow__c flow = Database.query(soqlString);

		d = GlobalUtilities.getAllFieldsWithoutSharing('Deployment_Flow_Step__c');
		soqlString = 'SELECT ' + d.get(Label.FIELDS) + ' FROM ' + d.get(Label.OBJECT) + ' WHERE Deployment_Flow__c =\'' + flow.Id + '\'';
		List<Deployment_Flow_Step__c> steps = Database.query(soqlString);
		System.debug(loggingLevel.Error, '*** steps: ' + steps);

		Deployment_Flow_Step__c testStep = steps[0];
		System.debug(loggingLevel.Error, '*** testStep: ' + testStep);

		Project__c project = [SELECT Id FROM Project__c LIMIT 1];

		Org__c org = [Select Id FROM Org__c WHERE Name = 'OrgDev1'];

		Release__c release = CMTestMethodUtilities.createRelease('Release1');
		release.Project__c = project.Id;
		insert release;
		System.assertNotEquals(release.Id, null);

		String flowResult = '[{"pullMergeResult":"MERGED","sourceBranch":"dev2","pullCompareCommits":"1d4e7459c2a53e0bdbc2267178dc6de469f41c27_vs_59d2898f7d338eec1fd1ab377bb61ef75387f010","pullCompareBranches":"uat_vs_dev2","filesMergedBehind":[{"d":"update","f":"objects/Contact.object"},{"d":"update","f":"objects/Account.object"}],"mergeTimestamp":"1500564866000","commitsBehind":6,"filesMergedConflictBehind":[],"commitsAhead":0,"pullDestinationCommit":"59d2898f7d338eec1fd1ab377bb61ef75387f010","pullSuccess":true,"filesMergedConflictAhead":[],"id":"a090Y000003NG0vQAG","pullSourceCommit":"1d4e7459c2a53e0bdbc2267178dc6de469f41c27","pullDone":true,"destinationBranch":"uat"},{"mergeCompareCommits":"fd928c33d8e0c175e45ae7cd8fc827e27be5abe7_vs_1d4e7459c2a53e0bdbc2267178dc6de469f41c27","pullMergeResult":"MERGED","sourceBranch":"dev1","pullCompareCommits":"1d4e7459c2a53e0bdbc2267178dc6de469f41c27_vs_fd928c33d8e0c175e45ae7cd8fc827e27be5abe7","mergeMergeResult":"MERGED","pullCompareBranches":"uat_vs_dev1","filesMergedBehind":[{"d":"update","f":"objects/Account.object"}],"mergeDone":true,"mergeTimestamp":"1503469473000","commitsBehind":1,"filesMergedConflictBehind":[],"commitsAhead":1,"pullDestinationCommit":"fd928c33d8e0c175e45ae7cd8fc827e27be5abe7","mergeDestinationCommit":"1d4e7459c2a53e0bdbc2267178dc6de469f41c27","mergeSuccess":true,"pullSuccess":true,"mergeCompareBranches":"dev1_vs_uat","mergeSourceCommit":"fd928c33d8e0c175e45ae7cd8fc827e27be5abe7","filesMergedConflictAhead":[],"id":"' + testStep.Id + '","pullSourceCommit":"1d4e7459c2a53e0bdbc2267178dc6de469f41c27","pullDone":true,"destinationBranch":"uat","filesMergedAhead":[{"d":"update","f":"objects/Account.object"},{"d":"update","f":"classes/IntegerConverter.cls"},{"d":"update","f":"classes/AccountOperations.cls"}]},{"mergeCompareCommits":"1d4e7459c2a53e0bdbc2267178dc6de469f41c27_vs_b6145d243f54736729456f0dd262a39ab8894f4d","sourceBranch":"uat","mergeMergeResult":"MERGED","mergeDone":true,"mergeTimestamp":"1501490921000","commitsBehind":0,"filesMergedConflictBehind":[],"commitsAhead":2,"mergeDestinationCommit":"b6145d243f54736729456f0dd262a39ab8894f4d","mergeSuccess":true,"mergeCompareBranches":"uat_vs_master","mergeSourceCommit":"1d4e7459c2a53e0bdbc2267178dc6de469f41c27","filesMergedConflictAhead":[],"id":"a090Y000003NG15QAG","destinationBranch":"master","filesMergedAhead":[{"d":"update","f":"objects/Contact.object"},{"d":"update","f":"workflows/Account.workflow"},{"d":"update","f":"objects/Account.object"}]}]';
		String stepResult = '{"mergeValidationDone":true,"pullValidationSuccess":false,"pullValidationDone":true,"mergeValidationStatus":"Completed","pullValidationErrors":[{"l":"ERROR","m":"Test failure, method: FieldMappingController_Test.test_method_one -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c]: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c] stack Class.FieldMappingController_Test.test_method_one: line 11, column 1","t":""},{"l":"ERROR","m":"Test failure, method: FieldMappingController_Test.test_method_two -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c]: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c] stack Class.FieldMappingController_Test.test_method_two: line 157, column 1","t":""},{"l":"ERROR","m":"Test failure, method: Test_RestIntegrationHandler.asyncSuccessfulCreate -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c]: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c] stack Class.Test_RestIntegrationHandler.asyncSuccessfulCreate: line 278, column 1","t":""},{"l":"ERROR","m":"Test failure, method: AccountOperationsTest.testAccountHasDefaultDescription -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c]: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c] stack Class.AccountOperationsTest.testAccountHasDefaultDescription: line 7, column 1","t":""},{"l":"ERROR","m":"Test failure, method: Test_RestIntegrationHandler.successfulCreateStdControl -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c]: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c] stack Class.Test_RestIntegrationHandler.successfulCreateStdControl: line 157, column 1","t":""},{"l":"ERROR","m":"Test failure, method: Test_RestIntegrationHandler.successfulCreate -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c]: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c] stack Class.Test_RestIntegrationHandler.successfulCreate: line 41, column 1","t":""},{"l":"ERROR","m":"Test failure, method: Test_RestIntegrationHandler.typeConversion -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c]: [Demo_Field__c, Integer_Demo_Field__c, Lenovo_Field__c] stack Class.Test_RestIntegrationHandler.typeConversion: line 439, column 1","t":""},{"l":"ERROR","m":"Code coverage issue:  -- Average test coverage across all Apex Classes and Triggers is 27%, at least 75% test coverage is required.","t":""}],"id":"' + testStep.Id + '","pullValidationStatus":"Completed","mergeValidationSuccess":false,"mergeValidationErrors":[{"l":"ERROR","m":"Test failure, method: FieldMappingController_Test.test_method_two -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c]: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c] stack Class.FieldMappingController_Test.test_method_two: line 157, column 1","t":""},{"l":"ERROR","m":"Test failure, method: FieldMappingController_Test.test_method_one -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c]: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c] stack Class.FieldMappingController_Test.test_method_one: line 11, column 1","t":""},{"l":"ERROR","m":"Test failure, method: AccountOperationsTest.testAccountHasDefaultDescription -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c]: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c] stack Class.AccountOperationsTest.testAccountHasDefaultDescription: line 7, column 1","t":""},{"l":"ERROR","m":"Test failure, method: Test_RestIntegrationHandler.successfulCreate -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c]: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c] stack Class.Test_RestIntegrationHandler.successfulCreate: line 41, column 1","t":""},{"l":"ERROR","m":"Test failure, method: Test_RestIntegrationHandler.successfulCreateStdControl -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c]: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c] stack Class.Test_RestIntegrationHandler.successfulCreateStdControl: line 157, column 1","t":""},{"l":"ERROR","m":"Test failure, method: Test_RestIntegrationHandler.typeConversion -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c]: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c] stack Class.Test_RestIntegrationHandler.typeConversion: line 439, column 1","t":""},{"l":"ERROR","m":"Test failure, method: Test_RestIntegrationHandler.asyncSuccessfulCreate -- System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c]: [Demo_Field__c, Lenovo_Field__c, Integer_Demo_Field__c] stack Class.Test_RestIntegrationHandler.asyncSuccessfulCreate: line 278, column 1","t":""},{"l":"ERROR","m":"Code coverage issue:  -- Average test coverage across all Apex Classes and Triggers is 27%, at least 75% test coverage is required.","t":""}]}';

		User_Story__c userStory = CMTestMethodUtilities.createUserStory('MyStory1');
		userStory.Project__c = project.Id;
		userStory.Release__c = release.Id;
		userStory.Org_Credential__c = org.Id;
		insert userStory;

		d = GlobalUtilities.getAllFieldsWithoutSharing('Git_Org_Commit__c');
		soqlString = 'SELECT ' + d.get(Label.FIELDS) + ' FROM ' + d.get(Label.OBJECT) + ' LIMIT 10';
		List<Git_Org_Commit__c> orgCommits = Database.query(soqlString);

		List<User_Story_Commit__c> usCommits = new List<User_Story_Commit__c>();
		for (Git_Org_Commit__c gc : orgCommits) {
			User_Story_Commit__c userStoryCommit = new User_Story_Commit__c(User_Story__c = userStory.id, Snapshot_Commit__c = gc.id);
			usCommits.add(userStoryCommit);
		}
		insert usCommits;

		Test.setCurrentPage(new PageReference('BranchManagement.Page'));

		System.currentPageReference().getParameters().put('fromEnvId', testStep.Source_Environment__c);
		System.currentPageReference().getParameters().put('toEnvId', testStep.Destination_Environment__c);
		System.currentPageReference().getParameters().put('envId', testStep.Source_Environment__c);
		System.currentPageReference().getParameters().put('type', 'pull');
		System.currentPageReference().getParameters().put('stepId', testStep.Id);
		System.currentPageReference().getParameters().put('flowId', flow.Id);
		System.currentPageReference().getParameters().put('flowResult', flowResult);
		System.currentPageReference().getParameters().put('stepResult', stepResult);

		BranchManagementExtension ext = new BranchManagementExtension(new ApexPages.StandardController(flow));

		ext.prepareOverlay();
		ext.errorsOverlay();
		ext.userStoriesOverlay();
		ext.showMergeDifferences();
		System.assertNotEquals(null, ext.latestOverlay);
	}
}