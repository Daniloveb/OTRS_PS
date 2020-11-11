# --
# Kernel/GenericInterface/Operation/LinkObject/LinkAdd.pm - GenericInterface LinkAdd operation backend
# Copyright (C) 2016 ArtyCo (Artjoms Petrovs), http://artjoms.lv/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::GenericInterface::Operation::LinkObject::LinkList;

use strict;
use warnings;

#use Kernel::GenericInterface::Operation::Common;
#use Kernel::System::LinkObject;

use Kernel::System::VariableCheck qw(IsStringWithData IsHashRefWithData);

#Log
    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new('Kernel::System::Log' => {LogPrefix => 'Danilov_Debug_record',},);

my $LogObject = $Kernel::OM->Get('Kernel::System::Log');



=head1 NAME

Kernel::GenericInterface::Operation::LinkObject::LinkList - GenericInterface Link Operation backend

=head1 SYNOPSIS

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

usually, you want to create an instance of this
by using Kernel::GenericInterface::Operation->new();

=cut

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for my $Needed (
        qw( DebuggerObject WebserviceID )
        )
    {
        if ( !$Param{$Needed} ) {
            return {
                Success      => 0,
                ErrorMessage => "Got no $Needed!"
            };
        }

        $Self->{$Needed} = $Param{$Needed};
    }

    # create additional objects
    #$Self->{CommonObject} = Kernel::GenericInterface::Operation::Common->new( %{$Self} );

#    local $Kernel::OM = Kernel::System::ObjectManager->new( %{$Self} );
    $Self->{LinkObject} = $Kernel::OM->Get('Kernel::System::LinkObject');


    return $Self;
}

=item Run()

Delete a link.

    my $Result = $OperationObject->Run(
        Data => {
            SourceObject => 'Ticket',
            SourceKey    => '321',
            TargetObject => 'Ticket',
            TargetKey    => '12345',
            Type         => 'ParentChild',
            State        => 'Valid',
            UserID       => 1,
        },
    );

    $Result = {
        Success      => 1,                                # 0 or 1
        ErrorMessage => '',                               # In case of an error
        Data         => {
            Result => 1,                                  # 0 or 1 
        },
    };

=cut

sub Run {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !IsHashRefWithData( $Param{Data} ) ) {
        return $Self->{DebuggerObject}->Error(
            ErrorCode    => 'LinkList.MissingParameter',
            ErrorMessage => "LinkList: The request is empty!",
        );
    }
my $p1 = shift;
my @a = @_;
my $s = scalar @_;

my $Links = $Self->{LinkObject}->LinkList(
        Object => $Param{Data}{Object},
        Key => $Param{Data}{Key},
        State => $Param{Data}{State},
        Type => $Param{Data}{Type},
        UserID => $Param{Data}{UserID},
            );


#$LogObject->Log(Priority => 'error',Message => $LinkID,);

    return {
        Success => 1,
        Data    => {
            Result => $Links,
        },
    };
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut