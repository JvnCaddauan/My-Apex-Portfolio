/*
    ############################################################
    # DISCLAIMER:
    #
    # This Apex code is intended for EDUCATIONAL and PORTFOLIO
    # demonstration purposes only. It is not for resale, reuse,
    # or redistribution in commercial production environments.
    #
    # All logic, structure, and naming have been modified or
    # aliased to protect intellectual property and to reflect
    # safe, fictional use cases.
    #
    # The author assumes no responsibility for any misuse,
    # mishandling, or legal consequences resulting from the
    # use of this code in any unauthorized context.
    #
    # Author: Joven Caddauan
    ############################################################
*/
public without sharing class BatchClone_CPQModel implements Database.Batchable<sObject>, Database.Stateful {
    
    private Id oppId;
    Map<Id, Id> opptMap = new Map<Id, Id>();
    Map<Id, Id> proposalMap = new Map<Id, Id>();
    
    public BatchClone_CPQModel(Id oppId) {
        this.oppId = oppId;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id FROM Opportunity WHERE Id =: oppId
        ]);
    }

    public void execute(Database.BatchableContext bc, Opportunity scope){
        // TODO: Cloning of Opportunity and Proposal
        if(scope.isEmpty()) {
            return;
        }

        if(!scope.isEmpty()) {
            cloneOpportunity(oppRecord);
        }
    }

    public void finish(Database.BatchableContext bc){
        // TODO: Enqueue Queueable for heavy cloning (Proposal Line Item, Proposal Line Group, Opportunity Product)
    }

    private static void cloneOpportunity(Opportunity oppRecord){
        Id originalId;
        Date dateToday = Date.today();

        Opportunity clonedOpp = oppRecord.clone(false, true, false, false);

        String opportunityName = (op.Name.contains(ConstantVariables.Opportunity.RENEWAL_NAME)) ? RenewalCloneName(oppRecord.Name) : clonedName(oppRecord.Name);
        clonedOpp.Name = opportunityName;
        clonedOpp.StageName = ConstantVariables.Opportunity.RENEWAL;
        clonedOpp.CloseDate = dateToday.addDays(180);
        clonedOpp.Type = ConstantVariables.Opportunity.TYPE;
        clonedOpp.Id = null;
        originalId = oppRecord.Id;

        insert clonedOpp;

        opptMap.put(originalId, clonedOpp.Id);
    }

    private static void cloneProposal(Map<Id, Id> opptMap){
        Proposal__c clonedProposal = new Proposal__c();
        List<Proposal__c> propList = QueryFactory.getProposal(opptMap);
        for(Proposal__c pr : propList) {
            if(opptMap.containsKey(pr.OpportunityId)) {
                Proposal__c clonedProposal = pr.clone(false, true, false, false);

                pr.Primary__c = true;
                pr.Type__c = ConstantVariables.Proposal.TYPE;

                clonedProposal.add(clonedProposal);
            }
        }

        if(!clonedProposal.isEmpty()) {
            insert clonedProposal;
        }
    }

    public static String cloneName(String name){
        String newClonedName;
        Date formattedDate = today.format('MM-dd-yyyy');
        if(name == null) {
            newClonedName = 'Unknown';

            return newClonedName;
        }

        newClonedName = 'Renewal ' +name+ ' - ' + formattedDate;

        return newClonedName;
    }

    public static String RenewalCloneName(String name){
        String newClonedName;
        Date formattedDate = today.format('MM-dd-yyyy');

        if(name == null) {
            newClonedName = 'Unknown';

            return newClonedName;
        }

        Pattern p = Pattern.compile('^(.*) - \\d{2}-\\d{2}-\\d{4}$');
        Matcher m = p.matcher(name);

        if (m.find()) {
            baseName = m.group(1);
        } else {
            baseName = name;
        }

        newClonedName = baseName + ' - ' + formattedDate;

        return newClonedName;
    }
}