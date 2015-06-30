<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Email_to_an_SurveyCreator</fullName>
        <description>Send Email to an SurveyCreator</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Low_Weightage_alert</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_to_an_SurveyCreator_s_Manager</fullName>
        <description>Send Email to an SurveyCreator&apos;s Manager</description>
        <protected>false</protected>
        <recipients>
            <field>Email_Sent_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Low_Weightage_alert</template>
    </alerts>
    <fieldUpdates>
        <fullName>AssignEmail</fullName>
        <field>Email_Sent_Address__c</field>
        <formula>Manager_Email__c</formula>
        <name>AssignEmail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>sendalert</fullName>
        <actions>
            <name>Send_Email_to_an_SurveyCreator</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Send_Email_to_an_SurveyCreator_s_Manager</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>AssignEmail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Completed__c  = true  &amp;&amp;  Avg_Weightage__c  &lt;  Survey__r.Threshold_Weightage__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
