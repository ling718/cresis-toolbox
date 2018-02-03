function cluster_hold(ctrl,hold_state)
% cluster_hold(ctrl,hold_state)
%
% Places or removes hold on specified batches.
%
% Inputs:
% ctrl = Several options which specify which batches to act on
%   1. Pass in a cluster batch ctrl structure (only needs "batch_dir"
%      defined)
%   2. A vector of batch ids to apply hold to
% hold_state = mode must be one of the following
%   0: removes hold
%   1: applies hold (default)
%
% Author: John Paden
%
% See also: cluster_batch_list cluster_cleanup cluster_compile ...
%   cluster_create_task cluster_hold cluster_job_list cluster_job_status ...
%   cluster_new_batch cluster_print cluster_rerun

if isstruct(ctrl)
  %% This section actually does the placement/removal of holds
  hold_fn = fullfile(ctrl.batch_dir,'hold');
  
  if ~exist('hold_state','var') || isempty(hold_state)
    % When no hold state passed in, then toggle the hold state
    if exist(hold_fn,'file')
      hold_state = 0;
    else
      hold_state = 1;
    end
  end
  
  if hold_state == 1
    fid = fopen(hold_fn,'w');
    fclose(fid);
    
  elseif hold_state == 0
    if exist(hold_fn,'file')
      delete(hold_fn);
    end
    return
  end
  
else
  %% Handle case where a non-structure method of identifying the batch was used
  if ~isstruct(ctrl)
    ctrls = cluster_batch_list;
    for batch_idx = 1:length(ctrls)
      if any(ctrls{batch_idx}.batch_id == ctrl)
        if hold_state == 1
          fprintf(' Placing hold on batch %d\n', ctrls{batch_idx}.batch_id);
        elseif hold_state == 0
          fprintf(' Removing hold on batch %d\n', ctrls{batch_idx}.batch_id);
        end
        cluster_hold(ctrls{batch_idx},hold_state);
      else
        fprintf(' Skipping %d\n', ctrls{batch_idx}.batch_id);
      end
    end
    return;
  end
end
