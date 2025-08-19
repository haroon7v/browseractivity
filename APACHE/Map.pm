package Apache::Ocsinventory::Plugins::Browseractivity::Map;
 
use strict;
 
use Apache::Ocsinventory::Map;
$DATA_MAP{browseractivity} = {
   mask => 0,
   multi => 1,
   auto => 1,
   delOnReplace => 1,
   sortBy => 'ACCESSEDAT',
   writeDiff => 0,
   cache => 0,
   fields => {
       URL => {},
       DOMAIN => {},
       TITLE => {},
       PROTOCOL => {},
       USERNAME => {},
       VISITTIME => {},
       DURATION => {}
   }
};
1;
