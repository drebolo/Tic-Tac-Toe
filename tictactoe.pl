#!/usr/bin/perl -w

# Tic Tac Toe;
# in portuguese: "O jogo do galo."

use strict;
use Data::Dumper;

my $grid = [['a1','b1','c1'],['a2','b2','c2'],['a3','b3','c3']];
my $available_slots = [ @{$grid->[0]}, @{$grid->[1]}, @{$grid->[2]}];
my $winners = [ ['a1','b1','c1'],
                ['a2','b2','c2'],
                ['a3','b3','c3'],
                ['a1','a2','a3'],
                ['b1','b2','b3'],
                ['c1','c2','c3'],
                ['a1','b2','c3'],
                ['a3','b2','c1']
                ];
 
my $plays = {};
my $players = {'A' => 'X','B' => 'O'};

my $play_count = 1;
my $have_winner = 0;
my $player_to_move = 'A';

my $game_mode = '2players';

my $arg = shift @ARGV;

print "Tic Tac Toe - Game \n\n";

if ($arg and $arg eq 'auto') {
    $game_mode = 'auto';
    automatic_game();
}
else {
    normal_game();
}

sub normal_game {
    choose_player_mark();
    print "Let's start playing: \n";
    while ( ($play_count < 10) and (not $have_winner)) {
        make_move();
    }
    draw_grid();
    if ($have_winner) {
        print "The Winner was player ".$player_to_move." in $play_count moves.\n";
    }
}

sub automatic_game {

    my $answer = ('X','O')[int (rand(2))]; 

    $players->{'A'} = $answer;
    $players->{'B'} = ($answer eq 'X' ? 'O' : 'X');
    
    print 'Player A you choosed mark: "'.$players->{'A'}.'"'."\n";
    print 'Player B you will play with mark: "'.$players->{'B'}.'"'."\n\n";
    print "Let's start playing: \n";
    
    while ( ($play_count < 10) and (not $have_winner)) {
        make_move();
    }
    draw_grid();
    if ($have_winner) {
        print "The Winner was player ".$player_to_move." in $play_count moves.\n";
    }
}

sub choose_player_mark {
    my $possible_answers = { 'X' => 1, 'O' => 1};
    my $answer = '';

    while ( not exists $possible_answers->{$answer} ) {
        print 'Player A choose your mark: ("X") or "O"'."\n";        
        $answer = <>;
        $answer =~ s/.*(X\?).*/$1/;
        chomp $answer;
        $answer = "X" if not $answer;
    }
    $players->{'A'} = $answer;
    $players->{'B'} = ($answer eq 'X' ? 'O' : 'X');
    
    print 'Player A you choosed mark: "'.$players->{'A'}.'"'."\n";
    print 'Player B you will play with mark: "'.$players->{'B'}.'"'."\n\n";
}

sub make_move {
    draw_grid();
    
    my $index = int (rand( @$available_slots ) );
    my $sugestion = $available_slots->[$index];   
    my $possible_answers = [@{$grid->[0]},@{$grid->[1]},@{$grid->[2]}];   
    my $answer = ' ';
    while (  not grep ( /^$answer$/, @$possible_answers) ) {
        print " Player $player_to_move make your move (ex: $sugestion)\n";
        if ($game_mode eq '2players') {
            $answer = <>;
            $answer =~ s/.*([abc]\?[123]\?).*/$1/g;
            chomp $answer;
        }
        else {
            $answer = '';
            sleep 5;
        }
        $answer = $sugestion if not $answer;
    }
    if (not grep {/$answer/} @$available_slots) {
        print " Player $player_to_move that slot has already been take, you have to choose another one!\n";
        make_move();    
    }
    else {
        $plays->{by_move}{$answer} = $players->{$player_to_move};
        push @{$plays->{by_player}{$player_to_move}}, $answer;
        do_we_have_winner();
        
        if (not $have_winner) {
            $play_count++;
            $player_to_move = ($player_to_move eq 'A' ? 'B' : 'A');
            if ($answer ne $sugestion) {
                $index = 0;
                foreach $a (@$available_slots) {
                    
                    print $a. " = " .$answer,"\n";
                    last if $a eq $answer;
                    $index++;
                }
            }
            splice (@$available_slots, $index, 1 );
        }
    }
}

sub draw_grid {
    my $row_count = 1;
    my $draw = '  a b c'."\n";

    foreach my $row (@$grid) {
        my $col_count = 1;
        $draw .= $row_count.' ';
        foreach my $col (@$row) {
            $draw .= ( exists $plays->{by_move}{$col} ? $plays->{by_move}{$col} : '_') if $row_count < 3;
            $draw .= ( exists $plays->{by_move}{$col} ? $plays->{by_move}{$col} : ' ') if $row_count == 3;
            $draw .= '|' if  $col_count < 3;
            $draw .= "\n" if $col_count == 3;
            $col_count++;
        }
        $row_count++;
    }
    print $draw,"\n";
}

sub do_we_have_winner {
    if (scalar @{$plays->{by_player}{$player_to_move}} >= 3) {

        foreach my $win ( @{$winners}) {
            my $exists = 0;
            foreach my $wincell (@{$win}) {
                
                if (grep { /$wincell/ } @{$plays->{by_player}{$player_to_move}}) {
                    $exists++;
                }
            }
            if ($exists == 3) {
                $have_winner = 1;
                last;
            }
        }
    }
}
