<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update1</fullName>
        <field>AssistantName</field>
        <name>Update1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update3</fullName>
        <field>Birthdate</field>
        <name>Update3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update4</fullName>
        <field>CleanStatus</field>
        <name>Update4</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>PreviousValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update5</fullName>
        <field>Department</field>
        <name>Update5</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update6</fullName>
        <field>Description</field>
        <name>Update6</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update7</fullName>
        <field>DoNotCall</field>
        <literalValue>1</literalValue>
        <name>Update7</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update8</fullName>
        <field>HasOptedOutOfEmail</field>
        <literalValue>1</literalValue>
        <name>Update8</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update9</fullName>
        <field>LeadSource</field>
        <name>Update9</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>PreviousValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>test1</fullName>
        <field>AssistantName</field>
        <name>test1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>test10</fullName>
        <field>OtherStreet</field>
        <name>test10</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>test2</fullName>
        <field>Birthdate</field>
        <name>test2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>test3</fullName>
        <field>Department</field>
        <name>test3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>test4</fullName>
        <field>Description</field>
        <name>test4</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>test5</fullName>
        <field>DoNotCall</field>
        <literalValue>1</literalValue>
        <name>test5</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>test6</fullName>
        <field>HasOptedOutOfFax</field>
        <literalValue>1</literalValue>
        <name>test6</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>test7</fullName>
        <field>HomePhone</field>
        <name>test7</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>test8</fullName>
        <field>MobilePhone</field>
        <name>test8</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>test9</fullName>
        <field>Phone</field>
        <name>test9</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>brown</fullName>
        <actions>
            <name>test1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>test2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>test3</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>test4</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>test5</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>test6</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>test7</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>test8</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>test9</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contact.AccountName</field>
            <operation>contains</operation>
            <value>test</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
