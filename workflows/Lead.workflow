<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update1</fullName>
        <field>HasOptedOutOfEmail</field>
        <literalValue>1</literalValue>
        <name>Update1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update10</fullName>
        <field>Phone</field>
        <name>Update10</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update2</fullName>
        <field>City</field>
        <name>Update2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update3</fullName>
        <field>Industry</field>
        <name>Update3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>PreviousValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update4</fullName>
        <field>Salutation</field>
        <name>Update4</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>PreviousValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update5</fullName>
        <field>HasOptedOutOfFax</field>
        <literalValue>1</literalValue>
        <name>Update5</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update62</fullName>
        <field>GeocodeAccuracy</field>
        <name>Update6(2)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>PreviousValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update7</fullName>
        <field>Description</field>
        <name>Update7</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update8</fullName>
        <field>Country</field>
        <name>Update8</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update9</fullName>
        <field>CleanStatus</field>
        <name>Update9</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>PreviousValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>snoopy</fullName>
        <actions>
            <name>Update1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update10</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update3</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update4</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update5</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update62</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update7</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update8</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update9</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Country</field>
            <operation>equals</operation>
            <value>Spain</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
