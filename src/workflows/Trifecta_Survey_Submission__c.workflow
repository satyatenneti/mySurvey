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
        <template>SurveyGuruEmails/TTISGLow_Weightage_alert</template>
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
        <template>SurveyGuruEmails/TTISGLow_Weightage_alert</template>
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
    <fieldUpdates>
        <fullName>Completion_Action</fullName>
        <field>Completion_Indicator__c</field>
        <literalValue>Completed</literalValue>
        <name>Completion Action</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Not_Completed_Action</fullName>
        <field>Completion_Indicator__c</field>
        <literalValue>Not Completed</literalValue>
        <name>Not Completed Action</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Weightage_greater_than_Threshold</fullName>
        <field>Weightage_Indicator__c</field>
        <literalValue>Greater Than Threshold</literalValue>
        <name>Weightage greater than Threshold</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Weightage_less_than_Threshold</fullName>
        <field>Weightage_Indicator__c</field>
        <literalValue>Less Than Threshold</literalValue>
        <name>Weightage less than Threshold</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Completion Rule</fullName>
        <actions>
            <name>Completion_Action</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Trifecta_Survey_Submission__c.Completed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Non Completion Rule</fullName>
        <actions>
            <name>Not_Completed_Action</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Trifecta_Survey_Submission__c.Completed__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Weightage greater than Threshold</fullName>
        <actions>
            <name>Weightage_greater_than_Threshold</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Avg_Weightage__c  &gt;  Survey__r.Threshold_Weightage__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Weightage less than Threshold</fullName>
        <actions>
            <name>Weightage_less_than_Threshold</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Avg_Weightage__c  &lt;  Survey__r.Threshold_Weightage__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
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
