package Ocsinventory::Agent::Modules::BrowserActivity;

use strict;
use warnings;

# Network calls
use LWP::UserAgent;

# Decode Network response.
use JSON;
use Time::Piece;
use URI;

sub new {
    my $name = "browseractivity";

    my (undef, $context) = @_;
    my $self = {};

    $self->{logger} = new Ocsinventory::Logger ({
        config => $context->{config}
    });

    $self->{logger}->{header}="[$name]";

    $self->{context}=$context;

    $self->{aw_bucket_client} = "aw-client-web";
    $self->{user_agent} = LWP::UserAgent->new(timeout => 10);

    $self->{structure} = {
        name => $name,
        start_handler => undef,
        prolog_writer => undef, 
        prolog_reader => undef, 
        inventory_handler => $name."_inventory_handler",
        end_handler => undef
    };

    bless $self;
}

######### Hook methods ############
sub browseractivity_inventory_handler {
    my $self = shift;
    my $logger = $self->{logger};
    my $common = $self->{context}->{common};
    my $aw_server_url = "http://localhost:5600/api/0";

    $logger->debug("Starting BrowserActivity plugin");

    # Fetch buckets
    my $buckets = $self->json_request("$aw_server_url/buckets/") || return;

    my $bucket_id;
    foreach my $key (keys %$buckets) {
        if ($self->is_browser_bucket($buckets->{$key})) {
            $bucket_id = $key;
            $logger->debug("Found bucket ID: $key");

            last;
        }
    }

    unless ($bucket_id) {
        $logger->error("No AW bucket found");
        return;
    }

    # Fetch events
    # 24 hours => 86400 seconds
    my $start_time = gmtime(time - 86400)->datetime . "Z";
    my $events_url = "$aw_server_url/buckets/$bucket_id/events?start=$start_time&limit=-1";

    my $events = $self->json_request($events_url) || return;

    $logger->debug("Fetched " . scalar(@$events) . " events");

    # Process events
    foreach my $event (@$events) {

        my $protocol = "Unknown";
        my $domain   = "Unknown";
        my $title    = $event->{data}->{title};
        my $source   = $event->{data}->{browser};

        eval {
            my $uri = URI->new($event->{data}->{url});
            $domain   = $uri->host;
            $protocol = $uri->scheme;
        };

        next if ($protocol ne "http" && $protocol ne "https");
        next if ($domain  eq "Unknown" || !$domain);

        # In Compression only 1 Bytes UTF is supported.
        $title =~ s/[^\x00-\xFF]//g;

        push @{$common->{xmltags}->{BROWSERACTIVITY}},
        {
            TITLE       => [$title],
            DOMAIN      => [$domain],
            PROTOCOL    => [$protocol],
            DURATION    => [$event->{duration}],
            ACCESSED_AT => [$event->{timestamp}],
            SOURCE      => [$source]
        };
    }

    $logger->debug("BrowserActivity plugin completed, appended XML");
}

sub json_request {
    my ($self, $url) = @_;
    my $logger = $self->{logger};

    $logger->debug("Fetching $url");

    my $http_resp = $self->{user_agent}->get($url);
    unless ($http_resp->is_success) {
        $logger->error("Failed to fetch $url: " . $http_resp->status_line);
        return;
    }

    my $json_reponse = eval {
        JSON->new->utf8->decode($http_resp->decoded_content);
    };

    if ($@) {
        $logger->error("JSON decode error $url: $@");
        return;
    }

    return $json_reponse;
}

sub is_browser_bucket {
    my ($self, $bucket) = @_;

    $bucket->{client} eq $self->{aw_bucket_client} && $bucket->{hostname} ne "unknown";
}

1;
