function savePB_callback(obj,hObj,event)
% savePB_callback(obj,hObj,event)

obj.status_text_set(sprintf('(%s) Saving...', datestr(now,'HH:MM:SS')),'replace');
drawnow;

imb.save_undo_stack(obj.undo_stack);

obj.status_text_set(sprintf('Done %s', datestr(now,'HH:MM:SS')),'append');

end
