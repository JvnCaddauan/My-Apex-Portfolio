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
    # Author: [Your Name or Initials]
    ############################################################
*/
public without sharing class FilterOpportunity {

    // Declare static values here
    public static final Integer MAXED_COUNT = 125;

    public static void runFilterOpportunity(){
        Map<Id, Integer> groupedResult = new Map<Id, Integer>();
        List<Opportunity> skipList = new List<Opportunity>();
        List<Opportunity> forCloneList = new List<Opportunity>();
        // Get the list of closed won opportunities
        List<Opportunity> oppList = QueryFactory.getOpportunities();

        if(oppList.isEmpty()){
            // TODO: Send an email where no opportunities to process
            return;
        }

        // Get the record count of the closed won opportunities
        // To determine the total count of Proposal Item (CPQ Model proposal item and opportunity line item are sync)
        List<Id> oppIds = new List<Id>();
        for(Opportunity op : oppList) {
            oppIds.add(op.Id);
        }

        // Aggregate the record count of the opportunity
        // If the count is greater than the allowed maximum, add to the skipList
        AggregateResult[] countRecord = QueryFactory.getResult(oppIds);

        for(AggregateResult ar : countRecord){
            groupedResult.put((Id) ar.get('OpportunityId'), (Integer) ar.get('recordCount'));
        }

        for (Opportunity opp : oppList) {
            Integer recordCount = groupedResult.containsKey(opId) ? groupedResult.get(opp.Id) : 0;

            if(recordCount < MAXED_COUNT){
                Id opId = opp.Id;
                Database.executeBatch(new BatchClone_CPQModel(opId), 1);
            }else{
                // Collect all opportunity Ids
                skipList.add(opp);
            }
        }

        // For all opportunities collected for email sending,
        EmailUtility.sendEmailBeforeClone(forCloneList);
        // Send email to skipped opportunities that has large volume of records
        EmailUtility.skippedOpportunities(skipList);
    }
}