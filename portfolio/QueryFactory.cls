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
public class QueryFactory {

    public static List<Opportunity> getOpportunities(){
        List<Opportunity> opList = [
            SELECT Id 
            FROM Opportunity 
            WHERE StageName = :ConstantVariables.Opportunity.CLOSED_WON
            WITH SECURITY_ENFORCED
        ];

        return opList;
    }

    public static AggregateResult[] getResult(List<Id> oppList) {
        AggregateResult[] countRecord = [
            SELECT OpportunityId, COUNT(Id) recordCount 
            FROM OpportunityLineItem 
            WHERE OpportunityId 
            IN: oppList WITH SECURITY_ENFORCED
        ];

        return countRecord;
    }
}