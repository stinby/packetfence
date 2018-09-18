package pfconfig::namespaces::resource::network_config;

=head1 NAME

pfconfig::namespaces::resource::network_config

=cut

=head1 DESCRIPTION

pfconfig::namespaces::resource::network_config

=cut

use strict;
use warnings;
use NetAddr::IP;
use pf::util;

use base 'pfconfig::namespaces::resource';
use pfconfig::namespaces::config::Network;
use pfconfig::namespaces::interfaces;
use pfconfig::namespaces::config::Cluster;

sub init {
    my ($self, $cluster_name) = @_;

    $self->{config_pf} = pfconfig::namespaces::config::Pf->new( $self->{cache} )->build();
    $self->{networks} = $self->{cache}->get_cache('config::Network');
    $self->{interfaces} = $self->{cache}->get_cache('interfaces');
    $self->{cluster_resource} = pfconfig::namespaces::config::Cluster->new($self->{cache});

}

sub build {
    my ($self) = @_;

    $self->{cluster_resource}->build();

    #TODO: handle this for multi-cluster
    return {};

    my %ConfigNetwork;

    foreach my $network ( keys %{$self->{networks}} ) {
        $ConfigNetwork{$network} = $self->{networks}{$network};
        foreach my $interface (@{$self->{interfaces}{'internal_nets'} // [] }) {
            my $ipe = $interface->tag("vip") || $interface->tag("ip");
            my $net_addr = NetAddr::IP->new($ipe,$interface->mask());
            my %interface;
            $interface{'ip'} = $ipe;
            $interface{'mask'} = $interface->mask();
            $interface{'int'} = $interface->tag("int");
            $interface{'cidr'} = $interface->desc();
            if ( defined($self->{networks}{$network}{'next_hop'})) {
                my $ip = new NetAddr::IP::Lite clean_ip($self->{networks}{$network}{'next_hop'});
                if ($net_addr->contains($ip)) {
                    $ConfigNetwork{$network}{'cluster_ips'} = join(',', map { $_->{"interface ".$interface{'int'}}->{ip}} @{$self->{cluster_resource}->{_servers}});
                    if(isenabled($self->{config_pf}->{active_active}->{dns_on_vip_only})) {
                        $ConfigNetwork{$network}{'dns_vip'} = $self->{cluster_resource}->{cfg}->{CLUSTER}->{'interface '. $interface{'int'}}->{ip} || $interface{'ip'};
                    }
                    $ConfigNetwork{$network}{'interface'} = \%interface;
                }
            } else {
                my $ip = new NetAddr::IP::Lite clean_ip($self->{networks}{$network}{'gateway'});
                if ($net_addr->contains($ip)) {
                    $ConfigNetwork{$network}{'cluster_ips'} = join(',', map { $_->{"interface ".$interface{'int'}}->{ip}} @{$self->{cluster_resource}->{_servers}});
                    if(isenabled($self->{config_pf}->{active_active}->{dns_on_vip_only})) {
                        $ConfigNetwork{$network}{'dns_vip'} = $self->{cluster_resource}->{cfg}->{CLUSTER}->{'interface '. $interface{'int'}}->{ip} || $interface{'ip'};
                    }
                    $ConfigNetwork{$network}{'interface'} = \%interface;
                }
            }
        }
    }
    return \%ConfigNetwork;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
USA.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:

