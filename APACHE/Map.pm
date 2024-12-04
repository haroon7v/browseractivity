package Apache::Ocsinventory::Plugins::Chromeactivity::Map;
 
use strict;
 
use Apache::Ocsinventory::Map;
$DATA_MAP{chromeactivity} = {
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
       SUBDOMAIN => {},
       PROTOCOL => {},
       USERNAME => {},
       ACCESSEDAT => {}
   }
};
1;
