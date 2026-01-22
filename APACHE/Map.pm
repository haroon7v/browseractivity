package Apache::Ocsinventory::Plugins::Browseractivity::Map;
 
use strict;
 
use Apache::Ocsinventory::Map;
$DATA_MAP{browseractivity} = {
   mask => 0,
   multi => 1,
   auto => 1,
   delOnReplace => 1,
   sortBy => 'ACCESSED_AT',
   writeDiff => 0,
   cache => 0,
   fields => {
      DOMAIN => {},
      TITLE => {},
      PROTOCOL => {},
      # USERNAME => {},
      # VISITTIME => {},
      DURATION => {},
      ACCESSED_AT => {},
      SOURCE => {}
   }
};
1;
