function [stageId, caseId] = global_to_stage_case(globalId, stageCaseCounts)
%GLOBAL_TO_STAGE_CASE Convert 1-based global case index to stage-local index.

remaining = globalId;
stageId = 1;
while remaining > stageCaseCounts(stageId)
    remaining = remaining - stageCaseCounts(stageId);
    stageId = stageId + 1;
end
caseId = remaining;
end
