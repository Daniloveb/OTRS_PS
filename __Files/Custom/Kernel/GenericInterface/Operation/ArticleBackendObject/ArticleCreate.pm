# --
# Copyright (C) 2001-2019 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::GenericInterface::Operation::ArticleBackendObject::ArticleCreate;

use strict;
use warnings;


#use parent qw(Kernel::System::Ticket::Article::Backend::Base);
use parent qw(Kernel::System::EventHandler);

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::System::Cache',
    'Kernel::System::CommunicationChannel',
    'Kernel::System::DB',
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
    'Kernel::System::DynamicFieldValue',
    'Kernel::System::Log',
    'Kernel::System::Main',
    'Kernel::System::Ticket::Article',
);


#Log
    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new('Kernel::System::Log' => {LogPrefix => 'Danilov_Debug_record',},);

my $LogObject = $Kernel::OM->Get('Kernel::System::Log');


sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    # init of event handler
    $Self->EventHandlerInit(
        Config => 'Ticket::EventModulePost',
    );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # check data - only accept undef or hash ref
    if ( defined $Param{Data} && ref $Param{Data} ne 'HASH' ) {

        return $Self->{DebuggerObject}->Error(
            Summary => 'Got Data but it is not a hash ref in Operation ArticleCreate backend)!'
        );
    }

my $ArticleBackendObject = $Kernel::OM->Get('Kernel::System::Ticket::Article::Backend::Chat');

#=========================================
#$LogObject->Log(Priority => 'error',Message => $Param{Data}{TicketID} );

my $ArticleID = $ArticleBackendObject->ArticleCreate(
        TicketID             => $Param{Data}{TicketID},
        SenderType           => 'agent',
	ChatMessageList      => [                                 # (required) Output from ChatMessageList()
            {
                ID              => 1,
                MessageText     => $Param{Data}{MessageText},
		CreateTime	=> $Param{Data}{CreateTime}, #'2014-04-04 10:10:10',
                SystemGenerated => 0,
                ChatterID       => $Param{Data}{ChatterID},
                ChatterType     => 'User',
                ChatterName     => 'ChatterName1 ChatterName2',
            },
	],
        IsVisibleForCustomer => $Param{Data}{IsVisibleForCustomer},
        UserID               => $Param{Data}{UserID},
	HistoryType          => 'AddNote',                          # EmailCustomer|Move|AddNote|PriorityUpdate|WebRequestCustomer|...
        HistoryComment       => 'HistoryComment text!',
);
#agent,system,customer

return {
    Success => 1,
    Data => {
    Result => $ArticleID,
    },
};

}