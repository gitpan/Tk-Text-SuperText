#!/usr/bin/perl
##
#
# $Author: alex $
# $Revision: 1.4 $
# $Log: SuperText.pm,v $
# Revision 1.4  1999/02/05 13:54:29  alex
# catch some errors on undo/redo pop
#
# Revision 1.3  1999/02/05 13:32:44  alex
# Fixed undo/redo blocks
#
# Revision 1.2  1999/02/04 11:25:46  alex
# First stable version
#
# Revision 1.1  1999/01/24 11:09:31  alex
# Initial revision
#
##

package Tk::Text::SuperText;
#package SuperText;

use AutoLoader;
require Tk::Text;
require Tk::Derived;

use Carp;
use strict;
use vars qw($VERSION @ISA);

$VERSION = '0.8';
@ISA = qw(Tk::Derived Tk::Text);

use base qw(Tk::Text);

import Tk qw(Ev);

Construct Tk::Widget 'SuperText';

# remove default Tk::Text key binds
sub RemoveTextBinds
{
	my ($class,$w) = @_;
	my (@binds) = $w->bind($class);
	
	foreach $b (@binds) {
		$w->bind($class,$b,"");
	}	
}

# returns an hash with the default events and key binds
sub DefaultEvents {
	my (%events);
	
	%events = (
		'MouseSetInsert'			=>	['<1>'],
		'MouseSelect'				=>	['<B1-Motion>'],
		'MouseSelectWord'			=>	['<Double-1>'],
		'MouseSelectLine'			=>	['<Triple-1>'],
		'MouseSelectAdd'			=>	['<Shift-1>'],
		'MouseSelectAddWord'		=>	['<Double-Shift-1>'],
		'MouseSelectAddLine'		=>	['<Triple-Shift-1>'],
		'MouseSelectAutoScan'		=>	['<B1-Leave>'],
		'MouseSelectAutoScanStop'	=>	['<B1-Enter>','<ButtonRelease-1>'],
		'MouseMoveInsert'			=>	['<Alt-1>'],
		'MouseRectSelection'		=>	['<Control-B1-Motion>'],
		'MouseMovePageTo'			=>	['<2>'],
		'MouseMovePage'			=>	['<B2-Motion>'],
		'MousePasteSelection'		=>	['<ButtonRelease-2>'],
		
		'MoveLeft'					=>	['<Left>'],
		'SelectLeft'				=>	['<Shift-Left>'],
		'SelectRectLeft'			=>	['<Shift-Alt-Left>'],
		'MoveLeftWord'				=>	['<Control-Left>'],
		'SelectLeftWord'			=>	['<Shift-Control-Left>'],
		'MoveRight'				=>	['<Right>'],
		'SelectRight'				=>	['<Shift-Right>'],
		'SelectRectRight'			=>	['<Shift-Alt-Right>'],
		'MoveRightWord'			=>	['<Control-Right>'],
		'SelectRightWord'			=>	['<Shift-Control-Right>'],
		'MoveUp'					=>	['<Up>'],
		'SelectUp'					=>	['<Shift-Up>'],
		'SelectRectUp'				=>	['<Shift-Alt-Up>'],
		'MoveUpParagraph'			=>	['<Control-Up>'],
		'SelectUpParagraph'		=>	['<Shift-Control-Up>'],
		'MoveDown'					=>	['<Down>'],
		'SelectDown'				=>	['<Shift-Down>'],
		'SelectRectDown'			=>	['<Shift-Alt-Down>'],
		'MoveDownParagraph'		=>	['<Control-Down>'],
		'SelectDownParagraph'		=>	['<Shift-Control-Down>'],
		'MoveLineStart'			=>	['<Home>'],
		'SelectToLineStart'		=>	['<Shift-Home>'],
		'MoveTextStart'			=>	['<Control-Home>'],
		'SelectToTextStart'		=>	['<Shift-Control-Home>'],
		'MoveLineEnd'				=>	['<End>'],
		'SelectToLineEnd'			=>	['<Shift-End>'],
		'MoveTextEnd'				=>	['<Control-End>'],
		'SelectToTextEnd'			=>	['<Shift-Control-End>'],
		'MovePageUp'				=>	['<Prior>'],
		'SelectToPageUp'			=>	['<Shift-Prior>'],
		'MovePageLeft'				=>	['<Control-Prior>'],
		'MovePageDown'				=>	['<Next>'],
		'SelectToPageDown'			=>	['<Shift-Next>'],
		'MovePageRight'			=>	['<Control-Next>'],
		'SetSelectionMark'			=>	['<Control-space>','<Select>'],
		'SelectToMark'				=>	['<Shift-Control-space>','<Shift-Select>'],
		'SelectAll'				=>	['<Control-a>'],
		'SelectionShiftLeft'		=>	['<Control-comma>'],
		'SelectionShiftLeftTab'	=>	['<Control-Alt-comma>'],
		'SelectionShiftRight'		=>	['<Control-period>'],
		'SelectionShiftRightTab'	=>	['<Control-Alt-period>'],
		
		'Insert'					=>	['<Insert>'],
		'Return'					=>	['<Return>'],
		'AutoIndentReturn'			=>	['<Control-Return>'],
		'NoAutoindentReturn'		=>	['<Shift-Return>'],
		'Delete'					=>	['<Delete>'],
		'BackSpace'				=>	['<BackSpace>'],
		'DeleteToWordStart'		=>	['<Shift-BackSpace>'],
		'DeleteToWordEnd'			=>	['<Shift-Delete>'],
		'DeleteToLineStart'		=>	['<Alt-BackSpace>'],
		'DeleteToLineEnd'			=>	['<Alt-Delete>'],
		'DeleteWord'				=>	['<Control-BackSpace>'],
		'DeleteLine'				=>	['<Control-Delete>'],
		
		'InsertControlCode'		=>	['<Control-Escape>'],
		
		'FocusNext'				=>	['<Control-Tab>'],
		'FocusPrev'				=>	['<Shift-Control-Tab>'],
		
		'FlashMatchingChar'		=>	['<Control-b>'],
		'FindMatchingChar'			=>	['<Control-j>'],
		
		'Escape'					=>	['<Escape>'],
		'Tab' 						=>	['<Tab>'],
		'LeftTab' 					=>	['<Shift-Tab>'],
		'Copy' 					=>	['<Control-c>'],
		'Cut' 						=>	['<Control-x>'],
		'Paste' 					=>	['<Control-v>'],
		'InlinePaste'				=>	['<Control-V>'],
		'Undo' 					=>	['<Control-z>'],
		'Redo' 					=>	['<Control-Z>'],
		
		'Destroy'					=>	['<Destroy>'],

		'KeyPress'					=>	['<KeyPress>'],
		'MenuSelect'				=>	['<Alt-KeyPress>'],
		
		'NoOP'						=>	['<Control-KeyPress>']
	);
	
	return %events;	
}

sub ClassInit
{
	my ($class,$w) = @_;
	
	$class->SUPER::ClassInit($w);

	# reset default Tk::Text binds
	$class->RemoveTextBinds($w);
	
	return $class;
}

sub Populate
{
	my	($w,@args) = @_;
	
	$w->SUPER::Populate(@args);

	# and set configuration parameters defaults
	$w->ConfigSpecs(
		'-indentmode'		=> ['PASSIVE','indentMode','IndentMode','auto'],
		'-undodepth'	 	=> ['PASSIVE','undoDepth','UndoDepth',undef],
		'-redodepth' 		=> ['PASSIVE','redoDepth','RedoDepth',undef],
		'-showmatching' 	=> ['PASSIVE','showMatching','ShowMatching',1],
		'-matchforeground'	=> ['METHOD','matchForeground','MatchForeground','white'],
		'-matchbackground'	=> ['METHOD','matchBackground','MatchBackground','blue'],
		'-matchingcouples'	=> ['METHOD','matchingCouples','MatchingCouples',"//[]{}()<>\\\\''``\"\""],
		'-insertmode'		=> ['METHOD','insertMode','InsertMode','insert']
	);
	# set default key binds and events
	$w->bindDefault;
	# set undo block flag
	$w->{UNDOBLOCK}=0;
}

# callbacks for options management

sub matchforeground
{
	my ($w,$val) = @_;
	
	if($val eq undef) {return $w->tagConfigure('match','-foreground');}
	$w->tagConfigure('match','-foreground' => $val);
}

sub matchbackground
{
	my ($w,$val) = @_;
	
	if($val eq undef) {return $w->tagConfigure('match','-background');}
	$w->tagConfigure('match','-background' => $val);
}

sub matchingcouples
{
	my ($w,$val) = @_;
	my ($i,$dir);
	

	if($val eq undef) {return $w->{MATCHINGCOUPLES_STRING};}
	$w->{MATCHINGCOUPLES_STRING}=$val;

	$w->{MATCHINGCOUPLES}={} unless exists $w->{MATCHINGCOUPLES};
	for($i=0;$i<length($val);$i++) {
		$dir=($i % 2 ? -1 : 1);
		if($dir == -1 && (substr($val,$i,1) eq substr($val,$i+$dir,1))) {next;}
		$w->{MATCHINGCOUPLES}->{substr($val,$i,1)}=[substr($val,$i+$dir,1),$dir];
	}
}

sub insertmode
{
	my ($w,$val) = @_;
	
	if($val eq undef) {return $w->{INSERTMODE};}
	$w->{INSERTMODE}=$val;
}

# insertion and deletion functions intereptors

sub insert
{
	my ($w,$index,$str,@tags) = @_;
	my $s = $w->index($index);
	my $i;

	# for line start hack
	$w->{LINESTART}=0;
	
	$w->markSet('undopos' => $s);
	# insert ascii code
	if((exists $w->{ASCIICODE}) && $w->{ASCIICODE} == 1) {
		if(($str ge ' ') && ($str le '?')) {$i=-0x20;}
		else {$i=0x7f-0x40;}
		$str=sprintf('%c',ord($str) + $i);
		$w->{ASCIICODE} = 0;
	}
	# manage overwrite mode,NOT optimal for undo,but... hey who uses overwrite mode???
	if($w->{INSERTMODE} eq 'overwrite') {
		$w->_BeginUndoBlock;
		if($w->compare($s,'<',$w->index("$s lineend"))) {$w->delete($s);}
	}
	$w->SUPER::insert($s,$str,@tags);

	# match coupled chars
	if((!defined $w->tag('ranges','sel')) && $w->cget('-showmatching') == 1) {
		if(exists %{$w->{MATCHINGCOUPLES}}->{$str}) {
			# calculate visible zone and search only in this one
			my ($l,$c) = split('\.',$w->index('end'));
			my ($slimit,$elimit) = $w->yview;
			
			$slimit=int($l*$slimit)+1;
			$slimit="$slimit.0";
			$elimit=int($l*$elimit);
			$elimit="$elimit.0";
			my $i=$w->findMetchingChar($str,$s,$slimit,$elimit);
			if(defined $i) {
				my $sel = Tk::catch {$w->tag('nextrange','match','1.0','end');};
				if(defined $sel) {$w->tag('remove','match','match.first');}
				$w->tag('add','match',$i,$w->index("$i + 1c"));
				$w->after(1000,[\&removeMatch,$w,$i]);
			}
		}
	}
	
	# combine 'trivial ' inserts into clumps
	if((length($str) == 1) && ($str ne "\n")) {
		my $t = $w->_TopUndo;
		if($t && $t->[0] =~ /delete$/ && $w->compare($t->[2],'==',$s)) {
			$t->[2] = $w->index('undopos');
			return;
		}
	}
	$w->_AddUndo('delete',$s,$w->index('undopos'));
	# for undo blocks
	if($w->{INSERTMODE} eq 'overwrite') {
		$w->_EndUndoBlock;
	}
}

sub delete
{
	my $w = shift;
	my $str = $w->get(@_);
	my $s = $w->index(shift);
	
	$w->{LINESTART}=0;
	$w->SUPER::delete($s,@_);
	$w->_AddUndo('insert',$s,$str);
}

# clipboard methods that must be overriden for rectangular selections

sub deleteSelected
{
	my $w = shift;
	
	if(!defined $Tk::selectionType || ($Tk::selectionType eq 'normal')) {
		$w->SUPER::deleteSelected;
	} elsif ($Tk::selectionType eq 'rect') {
		my ($sl,$sc) = split('\.',$w->index('sel.first'));
		my ($el,$ec) = split('\.',$w->index('sel.last'));
		my ($i,$x);
		
		# delete only text in the rectangular selection range
		$w->_BeginUndoBlock;
		for($i=$sl;$i<=$el;$i++) {
			my ($l,$c) = split('\.',$w->index("$i.end"));
			# check if selection is too right (??) for this line
			if($sc > $c) {next;}
			# and clip selection
			if($ec <= $c) {$x=$ec;}
			else { $x=$c;}
			
			$w->delete($w->index("$i.$sc"),$w->index("$i.$x"));
		}
		$w->_EndUndoBlock;
	}
}

sub getSelected
{
	my $w = shift;
	
	if(!defined $Tk::selectionType || ($Tk::selectionType eq 'normal')) {
		return $w->SUPER::getSelected;
	} elsif ($Tk::selectionType eq 'rect') {
		my ($sl,$sc) = split('\.',$w->index('sel.first'));
		my ($el,$ec) = split('\.',$w->index('sel.last'));
		my ($i,$x);
		my ($sel,$str);
		
		$sel="";
		
		# walk throught all the selected lines and add a sel tag
		for($i=$sl;$i<=$el;$i++) {
			my ($l,$c) = split('\.',$w->index("$i.end"));
			# check if  selection is too much to the right
			if($sc > $c) {next;}
			# or clif if too wide
			if($ec <= $c) {$x=$ec;}
			else { $x=$c;}
			$str=$w->get($w->index("$i.$sc"),$w->index("$i.$x"));
			# add a new line if not the last line
			if(substr($str,-1,1) ne "\n") {
				$str=$str."\n";
			}
			$sel=$sel.$str;
		}
		return $sel;
	}
}

# redefine SetCursor for parentheses highlight
sub SetCursor
{
	my $w = shift;
	my $str;
	
	$w->SUPER::SetCursor(@_);
	
	if((!defined $w->tag('ranges','sel')) && $w->cget('-showmatching') == 1) {
		if(exists %{$w->{MATCHINGCOUPLES}}->{$str=$w->get('insert','insert + 1c')}) {
			# calculate visible zone and search only in this one
			my ($l,$c) = split('\.',$w->index('end'));
			my ($slimit,$elimit) = $w->yview;
			
			$slimit=int($l*$slimit)+1;
			$slimit="$slimit.0";
			$elimit=int($l*$elimit);
			$elimit="$elimit.0";
			my $i=$w->findMetchingChar($str,'insert',$slimit,$elimit);
			if(defined $i) {
				my $sel = Tk::catch {$w->tag('nextrange','match','1.0','end');};
				if(defined $sel) {$w->tag('remove','match','match.first');}
				$w->tag('add','match',$i,$w->index("$i + 1c"));
				$w->after(1000,[\&removeMatch,$w,$i]);
			}
		}
	}
}	

# redefine SetCursor for parentheses highlight
sub Button1
{
	my $w = shift;
	my $str;
	
	$w->SUPER::Button1(@_);
	
	if((!defined $w->tag('ranges','sel')) && $w->cget('-showmatching') == 1) {
		if(exists %{$w->{MATCHINGCOUPLES}}->{$str=$w->get('insert','insert + 1c')}) {
			# calculate visible zone and search only in this one
			my ($l,$c) = split('\.',$w->index('end'));
			my ($slimit,$elimit) = $w->yview;
			
			$slimit=int($l*$slimit)+1;
			$slimit="$slimit.0";
			$elimit=int($l*$elimit);
			$elimit="$elimit.0";
			my $i=$w->findMetchingChar($str,'insert',$slimit,$elimit);
			if(defined $i) {
				my $sel = Tk::catch {$w->tag('nextrange','match','1.0','end');};
				if(defined $sel) {$w->tag('remove','match','match.first');}
				$w->tag('add','match',$i,$w->index("$i + 1c"));
				$w->after(1000,[\&removeMatch,$w,$i]);
			}
		}
	}
}	
1;

#__END__

# bind default keys with default events 
sub bindDefault
{
	my $w = shift;
	my (%events) = $w->DefaultEvents;
	
	foreach my $e (keys %events) {
		$w->eventAdd("<<$e>>",@{$events{$e}});
		$w->bind($w,"<<$e>>","_$e");
	}
}

# delete all event binds,specified event bind
sub bindDelete
{
	my ($w,$event,@triggers) = @_;
	
	if(!$event) {
		# delete all events binds
		my ($e);
		
		foreach $e ($w->DefaultEvents) {
			$w->eventDelete($e);
		}
		return;
	}
	$w->eventDelete($event,@triggers);
}

# Key binding Events subs

sub _BeginUndoBlock
{
	my $w = shift;

	$w->_AddUndo('#_BlockEnd_#');
}

sub _EndUndoBlock
{
	my $w = shift;

	$w->_AddUndo('#_BlockBegin_#');
}

# resets undo and redo buffers
sub resetUndo
{
	my $w = shift;
	
	delete $w->{UNDO};
	delete $w->{REDO};
}

# undo last operation
sub _Undo
{
	my ($w) = @_;
	my $s;
	my $op;
	my @args;
	my $block = 0;
	
	if(exists $w->{UNDO}) {
		if(@{$w->{UNDO}}) {
			# undo loop
			while(1) {
				# retrive undo command
				my ($op,@args) = Tk::catch{@{pop(@{$w->{UNDO}})};};

				if($op eq '#_BlockBegin_#') {
					$w->_AddRedo('#_BlockEnd_#');
					$block=1;
					next;
				} elsif($op eq '#_BlockEnd_#') {
					$w->_AddRedo('#_BlockBegin_#');
					return;
				}
				# convert for redo
				if($op =~ /insert$/) {
					# get current insert position
					$s = $w->index($args[0]);
					# mark for getting the with of the insertion
					$w->markSet('redopos' => $s);
				} elsif ($op =~ /delete$/) {
					# save text and position
					my $str = $w->get(@args);
					$s = $w->index($args[0]);
					
					$w->_AddRedo('insert',$s,$str);
				}
				# execute undo command
				$w->$op(@args);
				$w->SetCursor($args[0]);
				# insert redo command
				if($op =~ /insert$/) {
					$w->_AddRedo('delete',$s,$w->index('redopos'));
				}
				if($block == 0) {return;}
			}
		}
	}
	$w->bell;
}

# redo last undone operation
sub _Redo
{
	my ($w) = @_;
	my $block = 0;
	
	if(exists $w->{REDO}) {
		if(@{$w->{REDO}}) {
			while(1) {
				my ($op,@args) = Tk::catch{@{pop(@{$w->{REDO}})};};

				if($op eq '#_BlockBegin_#') {
					$w->_AddUndo('#_BlockEnd_#');
					$block=1;
					next;
				} elsif($op eq '#_BlockEnd_#') {
					$w->_AddUndo('#_BlockBegin_#');
					return;
				}
				$op =~ s/^SUPER:://;
				$w->$op(@args);
				$w->SetCursor($args[0]);
				if($block == 0) {return;}
			}
		}
	}
	$w->bell;
}

# add an undo command to the undo stack
sub _AddUndo
{
	my ($w,$op,@args) = @_;
	my ($usize,$udepth);
	
	$w->{UNDO} = [] unless(exists $w->{UNDO});
	# check for undo depth limit
	$usize = @{$w->{UNDO}} + 1;
	$udepth = $w->cget('-undodepth');
	
	if(defined $udepth) {
		if($udepth == 0) {return;}
		if($usize >= $udepth) {
			# free oldest undo sequence
			$udepth=$usize - $udepth + 1;
			splice(@{$w->{UNDO}},0,$udepth);
		}
	}
	if($op =~ /^#_/) {push(@{$w->{UNDO}},[$op]);}
	else {push(@{$w->{UNDO}},['SUPER::'.$op,@args]);}
}

# return the last added undo command
sub _TopUndo
{
	my ($w) = @_;
	
	return undef unless (exists $w->{UNDO});
	return $w->{UNDO}[-1];
}

# add a new redo command to the redo stack
sub _AddRedo
{
	my ($w,$op,@args) = @_;
	my ($rsize,$rdepth);
	
	$w->{REDO} = [] unless(exists $w->{REDO});
	
	# check for undo depth limit
	$rsize = @{$w->{REDO}} + 1;
	$rdepth = $w->cget('-undodepth');
	
	if(defined $rdepth) {
		if($rdepth == 0) {return;}
		if($rsize >= $rdepth) {
			# free oldest undo sequence
			$rdepth=$rsize - $rdepth + 1;
			splice(@{$w->{REDO}},0,$rdepth);
		}
	}
	if($op =~ /^#_/) {push(@{$w->{REDO}},[$op]);}
	else {push(@{$w->{REDO}},['SUPER::'.$op,@args]);}
}

# manage mouse normal and rectangular selections  for char,word or line mode
# overrides standard Tk::Text->SelectTo method
sub SelectTo
{
	my $w = shift;
	my $index = shift;
	$Tk::selectMode = shift if (@_);
	my $cur = $w->index($index);
	my $anchor = Tk::catch{$w->index('anchor')};

	# check for mouse movement
	if(!defined $anchor) {
		$w->markSet('anchor',$anchor=$cur);
		$Tk::mouseMoved=0;
	} elsif($w->compare($cur,"!=",$anchor)) {
		$Tk::mouseMoved=1;
	}
	$Tk::selectMode='char' unless(defined $Tk::selectMode);

	my $mode = $Tk::selectMode;
 	my ($first,$last);

	# get new selection limits
	if($mode eq 'char') {
		if($w->compare($cur,"<",'anchor')) {
			$first=$cur;
			$last='anchor';
		} else {
			$first='anchor';
			$last=$cur;
		}
	} elsif($mode eq 'word') {
		if($w->compare($cur,"<",'anchor')) {
			$first = $w->index("$cur wordstart");
			$last = $w->index("anchor - 1c wordend");
		} else {
			$first=$w->index("anchor wordstart");
			$last=$w->index("$cur wordend");
		}
	} elsif($mode eq 'line') {
		if($w->compare($cur,"<",'anchor')) {
			$first=$w->index("$cur linestart");
			$last=$w->index("anchor - 1c lineend + 1c");
		} else {
			$first=$w->index("anchor linestart");
			$last=$w->index("$cur lineend + 1c");
		}
	}
	# update selection
	if($Tk::mouseMoved || $Tk::selectMode ne 'char') {
		if((!defined $Tk::selectionType) || ($Tk::selectionType eq 'normal')) {
			# simple normal selection
			$w->tag('remove','sel','1.0',$first);
			$w->tag('add','sel',$first,$last);
			$w->tag('remove','sel',$last,'end');
			$w->idletasks;
		} elsif($Tk::selectionType eq 'rect') {
			my ($sl,$sc) = split('\.',$w->index($first));
			my ($el,$ec) = split('\.',$w->index($last));
			my $i;
			
			# swap min,max x,y coords
			if($sl >= $el) {($sl,$el)=($el,$sl);}
			if($sc >= $ec) {($sc,$ec)=($ec,$sc);}

			$w->tag('remove','sel','1.0','end');
			# add a selection tag to all the selected lines
			# FIXME: the selection's right limit is the line lenght of the line where mouse is on.BAD!!! 
			for($i=$sl;$i<=$el;$i++) {
				$w->tag('add','sel',"$i.$sc","$i.$ec");
			}
			$w->idletasks;
		}
	} 
}

sub _MouseSetInsert
{	
	my $w = shift;
	my $ev = $w->XEvent;

	$w->{LINESTART}=0;
	$w->Button1($ev->x,$ev->y);
}

sub _MouseSelect
{
	my $w = shift;
	my $ev = $w->XEvent;

	$Tk::selectionType='normal';
	$Tk::x=$ev->x;
	$Tk::y=$ev->y;
	$w->SelectTo($ev->xy);
}

sub _MouseSelectWord
{
	my $w = shift;
	my $ev = $w->XEvent;

	$Tk::selectionType='normal';
	$w->SelectTo($ev->xy,'word');
	Tk::catch {$w->markSet('insert',"sel.first")};
}

sub _MouseSelectLine
{
	my $w = shift;
	my $ev = $w->XEvent;

	$Tk::selectionType='normal';
	$w->SelectTo($ev->xy,'line');
	Tk::catch {$w->markSet('insert',"sel.first")};
}

sub _MouseSelectAdd
{
	my $w = shift;
	my $ev = $w->XEvent;

	$Tk::selectionType='normal';
	$w->ResetAnchor($ev->xy);	
	$w->SelectTo($ev->xy,'char');
}

sub _MouseSelectAddWord
{
	my $w = shift;
	my $ev = $w->XEvent;

	$Tk::selectionType='normal';
	$w->SelectTo($ev->xy,'word');
}

sub _MouseSelectAddLine
{
	my $w = shift;
	my $ev = $w->XEvent;

	$Tk::selectionType='normal';
	$w->SelectTo($ev->xy,'line');
}

sub _MouseSelectAutoScan
{
	my $w = shift;
	my $ev = $w->XEvent;

	$Tk::selectionType='normal';
	$Tk::x=$ev->x;
	$Tk::y=$ev->y;
	$w->AutoScan;
}

sub _MouseSelectAutoScanStop
{
	my $w = shift;

	$w->CancelRepeat;
}

sub _MouseMoveInsert
{
	my $w = shift;
	my $ev = $w->XEvent;

	$Tk::selectionType='normal';
	$w->markSet('insert',$ev->xy);
}

sub _MouseRectSelection
{
	my $w = shift;
	my $ev = $w->XEvent;

	$Tk::selectionType='rect';
	$Tk::x=$ev->x;
	$Tk::y=$ev->y;
	$w->SelectTo($ev->xy);
}

sub _MouseMovePageTo
{
	my $w = shift;
	my $ev = $w->XEvent;

	$w->Button2($ev->x,$ev->y);
}

sub _MouseMovePage
{
	my $w = shift;
	my $ev = $w->XEvent;

	$w->Motion2($ev->x,$ev->y);
}
    
sub _MousePasteSelection
{
	my $w = shift;
	my $ev = $w->XEvent;

	if(!$Tk::mouseMoved) {
		Tk::catch { $w->insert($ev->xy,$w->SelectionGet);};
	}
}


sub KeySelect
{
	my $w = shift;
	my $new = shift;
	my ($first,$last);
	if(!defined $w->tag('ranges','sel')) {
		# No selection yet
		$w->markSet('anchor','insert');
		if($w->compare($new,"<",'insert')) {
			$w->tag('add','sel',$new,'insert');
		} else {
			$w->tag('add','sel','insert',$new);
		}
	} else {
		# Selection exists
		if($w->compare($new,"<",'anchor')) {
			$first=$new;
			$last='anchor';
		} else {
			$first='anchor';
			$last=$new;
		}
		if((!defined $Tk::selectionType) || ($Tk::selectionType eq 'normal')) {
			$w->tag('remove','sel','1.0',$first);
			$w->tag('add','sel',$first,$last);
			$w->tag('remove','sel',$last,'end');
		} elsif($Tk::selectionType eq 'rect') {
			my ($sl,$sc) = split('\.',$w->index($first));
			my ($el,$ec) = split('\.',$w->index($last));
			my $i;
			
			# swap min,max x,y coords
			if($sl >= $el) {($sl,$el)=($el,$sl);}
			if($sc >= $ec) {($sc,$ec)=($ec,$sc);}

			$w->tag('remove','sel','1.0','end');
			# add a selection tag to all the selected lines
			# FIXME: the selection's right limit is the line lenght of the line where mouse is on.BAD!!! 
			for($i=$sl;$i<=$el;$i++) {
				$w->tag('add','sel',"$i.$sc","$i.$ec");
			}
		}
	}
	$w->markSet('insert',$new);
	$w->see('insert');
	$w->idletasks;
}

sub _MoveLeft
{
	my $w = shift;

	$w->{LINESTART}=0;
	$w->SetCursor($w->index("insert - 1c"));
}

sub _SelectLeft
{
	my $w = shift;

	$w->{LINESTART}=0;
	$Tk::selectionType='normal';
	$w->KeySelect($w->index("insert - 1c"));
}

sub _SelectRectLeft
{
	my $w = shift;

	$w->{LINESTART}=0;
	$Tk::selectionType='rect';
	$w->KeySelect($w->index("insert - 1c"));
}

sub _MoveLeftWord
{
	my $w = shift;

	$w->{LINESTART}=0;
	$w->SetCursor($w->index("insert - 1c wordstart"));
}

sub _SelectLeftWord
{
	my $w = shift;

	$w->{LINESTART}=0;
	$Tk::selectionType='normal';
	$w->KeySelect($w->index("insert - 1c wordstart"));
}

sub _MoveRight
{
	my $w = shift;

	$w->{LINESTART}=0;
	$w->SetCursor($w->index("insert + 1c"));
}

sub _SelectRight
{
	my $w = shift;

	$w->{LINESTART}=0;
	$Tk::selectionType='normal';
	$w->KeySelect($w->index("insert + 1c"));
}

sub _SelectRectRight
{
	my $w = shift;

	$w->{LINESTART}=0;
	$Tk::selectionType='rect';
	$w->KeySelect($w->index("insert + 1c"));
}

sub _MoveRightWord
{
	my $w = shift;

	$w->{LINESTART}=0;
	$w->SetCursor($w->index("insert + 1c wordend"));
}

sub _SelectRightWord
{
	my $w = shift;

	$w->{LINESTART}=0;
	$Tk::selectionType='normal';
	$w->KeySelect($w->index("insert wordend"));
}

sub _MoveUp
{
	my $w = shift;

	$w->{LINESTART}=0;
	$w->SetCursor($w->UpDownLine(-1));
}

sub _SelectUp
{
	my $w = shift;

	$w->{LINESTART}=0;
	$Tk::selectionType='normal';
	$w->KeySelect($w->UpDownLine(-1));
}

sub _SelectRectUp
{
	my $w = shift;

	$w->{LINESTART}=0;
	$Tk::selectionType='rect';
	$w->KeySelect($w->UpDownLine(-1));
}

sub _MoveUpParagraph
{
	my $w = shift;

	$w->{LINESTART}=0;
	$w->SetCursor($w->PrevPara('insert'));
}

sub _SelectUpParagraph
{
	my $w = shift;

	$w->{LINESTART}=0;
	$Tk::selectionType='normal';
	$w->KeySelect($w->PrevPara('insert'));
}

sub _MoveDown
{
	my $w = shift;

	$w->{LINESTART}=0;
	$w->SetCursor($w->UpDownLine(1));
}

sub _SelectDown
{
	my $w = shift;

	$w->{LINESTART}=0;
	$Tk::selectionType='normal';
	$w->KeySelect($w->UpDownLine(1));
}

sub _SelectRectDown
{
	my $w = shift;

	$w->{LINESTART}=0;
	$Tk::selectionType='rect';
	$w->KeySelect($w->UpDownLine(1));
}

sub _MoveDownParagraph
{
	my $w = shift;

	$w->{LINESTART}=0;
	$w->SetCursor($w->NextPara('insert'));
}

sub _SelectDownParagraph
{
	my $w = shift;

	$w->{LINESTART}=0;
	$Tk::selectionType='normal';
	$w->KeySelect($w->NextPara('insert'));
}

sub _MoveLineStart
{
	my $w = shift;
	
	if(exists $w->{LINESTART} && $w->{LINESTART} == 1) {
		$w->SetCursor('insert linestart');
		$w->{LINESTART}=0;
	} else {
		$w->{LINESTART}=1;
		my $str = $w->get('insert linestart','insert lineend');
		my $i=0;
	
		if($str =~ /^(\s+)(\S*)/) {
			if($2) {$i=length($1);}
			else {$i=0};
		}
		$w->SetCursor("insert linestart + $i c");
	}
}

sub _SelectToLineStart
{
	my $w = shift;

	$w->{LINESTART}=0;
	$Tk::selectionType='normal';
	$w->KeySelect('insert linestart');
}

sub _MoveTextStart
{
	my $w = shift;

	$w->{LINESTART}=0;
	$w->SetCursor('1.0');
}

sub _SelectToTextStart
{
	my $w = shift;

	$w->{LINESTART}=0;
	$Tk::selectionType='normal';
	$w->KeySelect('1.0');
}

sub _MoveLineEnd
{
	my $w = shift;

	$w->{LINESTART}=0;
	$w->SetCursor('insert lineend');
}

sub _SelectToLineEnd
{
	my $w = shift;

	$w->{LINESTART}=0;
	$Tk::selectionType='normal';
	$w->KeySelect('insert lineend');
}

sub _MoveTextEnd
{
	my $w = shift;

	$w->{LINESTART}=0;
	$w->SetCursor('end - 1c');
}

sub _SelectToTextEnd
{
	my $w = shift;

	$w->{LINESTART}=0;
	$Tk::selectionType='normal';
	$w->KeySelect('end - 1c');
}

sub ScrollPages
{
	my ($w,$count) = @_;
	my ($l,$c) = $w->index('end');
	my ($slimit,$elimit) = $w->yview;
	# get current page top and bottom line coords
	$slimit=int($l*$slimit)+1;
	$slimit="$slimit.0";
	$elimit=int($l*$elimit);
	$elimit="$elimit.0";
	# position insert cursor at text begin/end if the text is scrolled to begin/end
	if($count < 0 && $w->compare($slimit,'<=','1.0')) {return('1.0');}
	elsif($count >= 0 && $w->compare($elimit,'>=','end')) {return('end');}
	else {return $w->SUPER::ScrollPages($count);}
}
	
sub _MovePageUp
{
	my $w = shift;

	$w->{LINESTART}=0;
	$w->SetCursor($w->ScrollPages(-1));
}

sub _SelectToPageUp
{
	my $w = shift;

	$w->{LINESTART}=0;
	$Tk::selectionType='normal';
	$w->KeySelect($w->ScrollPages(-1));
}

sub _MovePageLeft
{
	my $w = shift;

	$w->{LINESTART}=0;
	$w->xview('scroll',-1,'page');
}

sub _MovePageDown
{
	my $w = shift;

	$w->{LINESTART}=0;
	$w->SetCursor($w->ScrollPages(1));
}

sub _SelectToPageDown
{
	my $w = shift;

	$w->{LINESTART}=0;
	$Tk::selectionType='normal';
	$w->KeySelect($w->ScrollPages(1));
}

sub _MovePageRight
{
	my $w = shift;

	$w->{LINESTART}=0;
	$w->xview('scroll',1,'page');
}

sub _SetSelectionMark
{
	my $w = shift;

	$w->{LINESTART}=0;
	$w->markSet('anchor','insert');
}

sub _SelectToMark
{
	my $w = shift;

	$w->{LINESTART}=0;
	$Tk::selectionType='normal';
	$w->SelectTo('insert','char');
}

sub _SelectAll
{
	my $w = shift;

	$w->{LINESTART}=0;
	$Tk::selectionType='normal';
	$w->tag('add','sel','1.0','end');
}

sub _SelectionShiftLeft
{
	my $w = shift;
	
	$w->{LINESTART}=0;
	$w->_SelectionShift(" ","left");
}

sub _SelectionShiftLeftTab
{
	my $w = shift;
	
	$w->{LINESTART}=0;
	$w->_SelectionShift("\t","left");
}

sub _SelectionShiftRight
{
	my $w = shift;
	
	$w->{LINESTART}=0;
	$w->_SelectionShift(" ","right");
}

sub _SelectionShiftRightTab
{
	my $w = shift;
	
	$w->{LINESTART}=0;
	$w->_SelectionShift("\t","right");
}

sub _SelectionShift
{
	my ($w,$type,$dir) = @_;
	
	if((!defined $type) || (!defined $dir)) {return;}
	if(!defined $w->tag('ranges','sel')) {return;}
	
	my ($sline,$scol) = split('\.',$w->index('sel.first'));
	my ($eline,$ecol) = split('\.',$w->index('sel.last'));
	
	my $col;
	if($Tk::selectionType eq 'rect') {$col=$scol;}
	else {$col=0;}
	
	if($ecol == 0) {$eline--;}
	
	$w->_BeginUndoBlock;
	if($dir eq "left") {
		if($scol != 0) {$scol--;}
		$w->delete($w->index("$sline.$scol"));
		for(my $i=$sline+1;$i <= $eline;$i++) {
			$w->delete($w->index("$i.$col"));
		}
	} elsif($dir eq "right") {
		$w->insert($w->index("$sline.$scol"),$type);
		for(my $i=$sline+1;$i <= $eline;$i++) {
			$w->insert($w->index("$i.$col"),$type);
		}
	}
	$w->_EndUndoBlock;
}

sub _Insert
{
	my $w = shift;

	$w->{LINESTART}=0;
	if($w->{INSERTMODE} eq 'insert') {$w->{INSERTMODE}='overwrite';}
	elsif($w->{INSERTMODE} eq 'overwrite') {$w->{INSERTMODE}='insert';}
}

sub _Return
{
	my $w = shift;

	Tk::catch {$w->Insert("\n")};
	if($w->cget('-indentmode') eq 'auto') {
		$w->_AutoIndent;
	}
}

sub _AutoIndentReturn
{
	my $w = shift;

	Tk::catch {$w->Insert("\n")};
	$w->_AutoIndent;
}

sub _NoAutoindentReturn
{
	my $w = shift;

	Tk::catch {$w->Insert("\n")};
}

sub _AutoIndent
{
	my $w = shift;
	my ($line,$col) = split('\.',$w->index('insert'));

	# no autoindent for first line
	if($line == 1) {return;}
	$line--;
	my $s=$w->get("$line.0","$line.end");
	if($s =~ /^(\s+)(\S*)/) {$s=$1;}
	else {$s='';}
	if($2) {
		$w->insert('insert linestart',$s);
	}
}

sub _Delete
{
	my $w = shift;

	$w->Delete;
}

# overrides Tk::Text->Delete method
sub Delete
{
	my $w = shift;
	my $sel = Tk::catch {$w->tag('nextrange','sel','1.0','end');};
	
	if(defined $sel) {
		$w->deleteSelected;
	} else {
		$w->delete('insert');
		$w->see('insert');
	}
}

sub _BackSpace
{
	my $w = shift;

	$w->Backspace;
}

# overrides Tk::Text->Backspace method
sub Backspace
{
	my $w = shift;
	my $sel = Tk::catch {$w->tag('nextrange','sel','1.0','end');};
	
	if(defined $sel) {
		$w->deleteSelected;
	} elsif($w->compare('insert',"!=",'1.0')) {
		$w->delete('insert - 1c');
		$w->see('insert');
	}	
}

sub _DeleteToWordStart
{
	my $w = shift;
	
	if($w->compare('insert','==','insert wordstart')) {
		$w->delete('insert - 1c');
	} else {
		$w->delete('insert wordstart','insert');
	}
}

sub _DeleteToWordEnd
{
	my $w = shift;
	
	if($w->compare('insert','==','insert wordend')) {
		$w->delete('insert');
	} else {
		$w->delete('insert','insert wordend');
	}
}

sub _DeleteToLineStart
{
	my $w = shift;

	if($w->compare('insert','==','1.0')) {return;}
	if($w->compare('insert','==','insert linestart')) {
		$w->delete('insert - 1c');
	} else {
		$w->delete('insert linestart','insert');
	}
}

sub _DeleteToLineEnd
{
	my $w = shift;
	
	if($w->compare('insert','==','insert lineend')) {
		$w->delete('insert');
	} else {
		$w->delete('insert','insert lineend');
	}
}

sub _DeleteWord
{
	my $w = shift;

	$w->delete('insert wordstart','insert wordend');
}

sub _DeleteLine
{
	my $w = shift;

	$w->delete('insert linestart','insert lineend + 1c');
	$w->markSet('insert','insert linestart');
}

sub _InsertControlCode
{
	my $w = shift;
	
	$w->{LINESTART}=0;
	$w->{ASCIICODE} = 1;
}

sub _FocusNext
{
	my $w = shift;

	$w->focusNext;
}

sub _FocusPrev
{
	my $w = shift;

	$w->focusPrev;
}

# find a matching char for the given one
sub findMetchingChar
{
	my ($w,$sc,$pos,$slimit,$elimit) = @_;
	my $mc = ${$w->{MATCHINGCOUPLES}->{$sc}}[0];	# char to search
	
	if(!defined $mc) {return undef;}
	
	my $dir = ${$w->{MATCHINGCOUPLES}->{$sc}}[1];	# forward or backward search
	my $spos=$w->index("$pos + $dir c");
	my $d = 1;
	my ($p,$c);
	
	if($dir == 1) {	# forward search
		for($p=$spos;$w->compare($p,'<',$elimit);$p=$w->index("$p + 1c")) {
			$c=$w->get($p);
			if($c eq $mc) {
				$d--;
				if($d == 0) {
					return $p;
				}
			} elsif($c eq $sc) {$d++;}
			Tk::DoOneEvent(Tk::DONT_WAIT);
		}
	} else {	# backward search
		for($p=$spos;$w->compare($p,'>=',$slimit);$p=$w->index("$p - 1c")) {
			$c=$w->get($p);
			if($c eq $mc) {
				$d--;
				if($d == 0) {
					return $p;
				}
			} elsif($c eq $sc) {$d++;}
			if($w->compare($p,'==','1.0')) {return undef;}
			Tk::DoOneEvent(Tk::DONT_WAIT);
		}
	}
	return undef;
}

sub _FlashMatchingChar
{
	my $w = shift;
	my $s = $w->index('insert');
	my $str = $w->get('insert');
	
	if(exists %{$w->{MATCHINGCOUPLES}}->{$str}) {
		my $i=$w->findMetchingChar($str,$s,"1.0","end");
		if(defined $i) {
			my $sel = Tk::catch {$w->tag('nextrange','match','1.0','end');};
			if(defined $sel) {$w->tag('remove','match','match.first');}
			$w->tag('add','match',$i,$w->index("$i + 1c"));
			$w->after(1500,[\&removeMatch,$w,$i]);
			return $i;
		}
	}
	return undef;
}

sub _FindMatchingChar
{
	my $w = shift;
	my $i = $w->_FlashMatchingChar;
	
	if(defined $i) {$w->see($i);}
}

# used for removing match tag after some time
sub removeMatch
{
	my ($w,$i) = @_;
	
	$w->tag('remove','match',$i);
}


sub _Escape
{
	my $w = shift;
	$w->tag('remove','sel','1.0','end');
}

sub _Tab
{
	my $w = shift;

	$w->Insert("\t");
	$w->focus;
	$w->break;
}

sub _LeftTab
{
}

sub _Copy
{
	my $w = shift;

	$w->clipboardCopy;
}

sub _Cut
{
	my $w = shift;

	$w->clipboardCut;
}

sub _Paste
{
	my $w = shift;

	$w->clipboardPaste;
}

sub _InlinePaste
{
	my $w = shift;
	my ($l,$c) = split('\.',$w->index('insert'));
	my $str;	
	Tk::catch{$str=$w->clipboardGet;};
	
	if($str eq "") {return;}
	$w->_BeginUndoBlock;
	while($str =~ /(.*)\n+/g) {
		$w->insert("$l.$c",$1);
		my ($el,$ec) = split('\.',$w->index('end'));
		if($l == $el) {$w->insert('end',"\n");}
		$l++;
		Tk::DoOneEvent(Tk::DONT_WAIT);
	}
	$w->_EndUndoBlock;
}

sub _Destroy
{
	my $w = shift;

	$w->Destroy;
}

sub _KeyPress
{
	my $w = shift;
	my $ev = $w->XEvent;

	$w->Insert($ev->A);
}

sub _MenuSelect
{
	my $w = shift;
	my $ev = $w->XEvent;

	$w->TraverseToMenu($ev->K);
}

sub _NoOP
{
	my $w = shift;
	$w->NoOp;
}

1;
__END__

=pod

=head1 NAME

Tk::Text::SuperText - An improved text widget for perl/tk

=head1 SYNOPSIS

I<$super_text> = I<$paren>-E<gt>B<SuperText>(?I<options>?);

=head1 STANDARD OPTIONS

B<-background>	B<-highlightbackground>	B<-insertontime>	B<-selectborderwidth>
B<-borderwidth>	B<-highlightcolor>	B<-insertwidth>	B<-selectforeground>
B<-cursor>	B<-highlightthickness>	B<-padx>	B<-setgrid>
B<-exportselection>	B<-insertbackground>	B<-pady>	B<-takefocus>
B<-font>	B<-insertborderwidth>	B<-relief>	B<-xscrollcommand>
B<-foreground>	B<-insertofftime>	B<-selectbackground>	B<-yscrollcommand>

See L<Tk::options> for details of the standard options.

B<-height>	B<-spacing1>	B<-spacing2>	B<-spacing3>
B<-state>	B<-tabs>	B<-width>	B<-wrap>

See L<Tk::Text> for details of theis options.

=head1 WIDGET-SPECIFIC OPTIONS

=over 4

=item Name:	B<indentMode>

=item Class:	B<IndentMode>

=item Switch:	B<-indentmode>

Specifies how to indent when a new line is inserted in the text.
The possible modes are B<none> for no indent at all or B<auto> for positioning
the insertion cursor right below the first non-white space character of the previous line.

=item Name:	B<undoDepth>

=item Class:	B<UndoDepth>

=item Switch:	B<-undodepth>

Sets the maximum depth for the undo buffer:a number specifies the numbers of 
insert or delete operations that can be stored in the buffer before the oldest one is
poped out and forgotten;B<0> stops the undo feature,B<undef> sets unlimited
depth.

=item Name:	B<redoDepth>

=item Class:	B<RedoDepth>

=item Switch:	B<-redodepth>

Sets the maximum depth for the redo buffer:a number specifies the numbers of 
undo operations that can be stored in the buffer before the oldest one is poped
out and forgotten;B<0> stops the redo feature,B<undef> sets unlimited depth.

=item Name:	B<showMatching>

=item Class:	B<ShowMatching>

=item Switch:	B<-showmatching>

With a value of B<1> activates the matching parentheses feature.B<0> deactivates it.

=item Name:	B<matchForeground>

=item Class:	B<MatchForeground>

=item Switch:	B<-matchforeground>

Set the foreground color for the char hilighted by the match-parentheses command.

=item Name:	B<showMatching>

=item Class:	B<ShowMatching>

=item Switch:	B<-matchbackground>

Set the background color for the char hilighted by the match-parentheses command.

=item Name:	B<matchingCouples>

=item Class:	B<MatchingCouples>

=item Switch:	B<-matchingcouples>

Sets the chars that are searched for a matching counterpart.
The format is a simple string with matching chars coupled in left-right order;
here's an example: I<{}[]()""> .
For double couples (I<"">) the match is done only on the forwarding chars.

=item Name:	B<insertMode>

=item Class:	B<InsertMode>

=item Switch:	B<-insertmode>

Sets the default insert mode: B<insert> or B<overwrite> .

=back

=head1 DESCRIPTION

B<Tk::Text::SuperText> implements many new features over the 
standard L<Tk::Text> widget while supporting all it's standard 
features.Its used simply as the L<Tk::Text> widget.
New Features:

=over 4

=item * Unlimited undo/redo.

So you can undo and redo whatever you deleted/inserted whenever you want.
To reset the undo and redo buffers call this method:
I<$w>-E<gt>B<resetUndo>;

=item * Rectangular selections.

Rectangular text zones can be selected,copied,deleted,shifted with the mouse
or with the keyboard.

=item * Selection right/left char and tab shift.

Text selections can be shifted left/right of  one or more chars or a tabs.

=item * Normal and 'inline' selection paste.

The 'normal' paste is the normal text paste you know :

=over 4

=item Paste Buffer:

line x

line y

=back

=over 4

=item Text Buffer:

line 1

line2

=back


=over 4

=item Normal paste at line 1:

I<line x>

I<line y>

line 1

line 2

=back

=over 4

=item The 'inline' paste work as this:

=item Inline paste at line 1:

I<line x> line 1

I<line y> line 2

=back

=item * Parentheses matching.

To help you inspect nested parentheses,brackets and other characters,B<SuperText>
has both an automatic parenthesis matching mode,and a find matching command.
Automatic parenthesis matching is activated when you type or when you move the
insertion cursor after a parenthesis.It momentarily highlightsthe matching character
if that character is visible in the window.To find a matching character anywhere in the
file,position the cursor after the it,and call the find matching command.

=item * Autoindenting.

When you press the Return or Enter key,spaces and tabs are inserted to line up the
insert point under the start of the previous line.

=item * Control codes insertion.

You can directly insert a non printable control character in the text.

=item * Commands are managed via virtual events.

Every B<SuperText> command is binded to a virtual event,so to call it or to bind it
to a key sequence use the L<Tk::event> functions.
I used this format for key bind so there's no direct key-to-command bind,and this
give me more flexibility;however you can use normal binds.

Example: I<$w>-E<gt>B<eventAdd>(I<'Tk::Text::SuperText','E<lt>E<lt>SelectAllE<gt>E<gt>','E<lt>Control-aE<gt>'>);

To set default events bindigs use this methos:
I<$w>-E<gt>B<bindDefault>;

=item * Key bindings are sometimes redefined (not really a feature :).

Virtual Event/Command		Default Key Binding

B<MouseSetInsert>			B<E<lt>Button1E<gt>>
B<MouseSelect>			B<E<lt>B1-MotionE<gt>>
B<MouseSelectWord>		B<E<lt>Double-1E<gt>>
B<MouseSelectLine>		B<E<lt>Triple-1E<gt>>
B<MouseSelectAdd>			B<E<lt>Shift-1E<gt>>
B<MouseSelectAddWord>		B<E<lt>Double-Shift-1E<gt>>
B<MouseSelectAddLine>		B<E<lt>Triple-Shift-1E<gt>>
B<MouseSelectAutoScan>		B<E<lt>B1-LeaveE<gt>>
B<MouseSelectAutoScanStop>	B<E<lt>B1-EnterE<gt>>,B<E<lt>ButtonRelease-1E<gt>>
B<MouseMoveInsert>		B<E<lt>Alt-1E<gt>>
B<MouseRectSelection>		B<E<lt>Control-B1-MotionE<gt>>
B<MouseMovePageTo>		B<E<lt>2E<gt>>
B<MouseMovePage>			B<E<lt>B2-MotionE<gt>>
B<MousePasteSelection>		B<E<lt>ButtonRelease-2E<gt>>

B<MoveLeft>				B<E<lt>LeftE<gt>>
B<SelectLeft>			B<E<lt>Shift-LeftE<gt>>
B<SelectRectLeft>			B<E<lt>Shift-Alt-LeftE<gt>>
B<MoveLeftWord>			B<E<lt>Control-LeftE<gt>>
B<SelectLeftWord>			B<E<lt>Shift-Control-LeftE<gt>>
B<MoveRight>				B<E<lt>RightE<gt>>
B<SelectRight>			B<E<lt>Shift-RightE<gt>>
B<SelectRectRight>		B<E<lt>Shift-Alt-RightE<gt>>
B<MoveRightWord>			B<E<lt>Control-RightE<gt>>
B<SelectRightWord>		B<E<lt>Shift-Control-RightE<gt>>
B<MoveUp>				B<E<lt>UpE<gt>>
B<SelectUp>				B<E<lt>Shift-UpE<gt>>
B<SelectRectUp>			B<E<lt>Shift-Alt-UpE<gt>>
B<MoveUpParagraph>		B<E<lt>Control-UpE<gt>>
B<SelectUpParagraph>		B<E<lt>Shift-Control-UpE<gt>>
B<MoveDown>				B<E<lt>DownE<gt>>
B<SelectDown>			B<E<lt>Shift-DownE<gt>>
B<SelectRectDown>			B<E<lt>Shift-Alt-DownE<gt>>
B<MoveDownParagraph>		B<E<lt>Control-DownE<gt>>
B<SelectDownParagraph>		B<E<lt>Shift-Control-DownE<gt>>
B<MoveLineStart>			B<E<lt>HomeE<gt>>
B<SelectToLineStart>		B<E<lt>Shift-HomeE<gt>>
B<MoveTextStart>			B<E<lt>Control-HomeE<gt>>
B<SelectToTextStart>		B<E<lt>Shift-Control-HomeE<gt>>
B<MoveLineEnd>			B<E<lt>EndE<gt>>
B<SelectToLineEnd>		B<E<lt>Shift-EndE<gt>>
B<MoveTextEnd>			B<E<lt>Control-EndE<gt>>
B<SelectToTextEnd>		B<E<lt>Shift-Control-EndE<gt>>
B<MovePageUp>			B<E<lt>PriorE<gt>>
B<SelectToPageUp>			B<E<lt>Shift-PriorE<gt>>
B<MovePageLeft>			B<E<lt>Control-PriorE<gt>>
B<MovePageDown>			B<E<lt>NextE<gt>>
B<SelectToPageDown>		B<E<lt>Shift-NextE<gt>>
B<MovePageRight>			B<E<lt>Control-NextE<gt>>
B<SetSelectionMark>		B<E<lt>Control-spaceE<gt>>,B<E<lt>SelectE<gt>>
B<SelectToMark>			B<E<lt>Shift-Control-spaceE<gt>>,B<E<lt>Shift-SelectE<gt>>

B<SelectAll>				B<E<lt>Control-aE<gt>>
B<SelectionShiftLeft>		B<E<lt>Control-commaE<gt>>
B<SelectionShiftLeftTab>	B<E<lt>Control-Alt-commaE<gt>>
B<SelectionShiftRight>		B<E<lt>Control-periodE<gt>>
B<SelectionShiftRightTab>	B<E<lt>Control-Alt-periodE<gt>>

B<Insert>				B<E<lt>InsertE<gt>>
B<Return>				B<E<lt>ReturnE<gt>>
B<AutoIndentReturn>		B<E<lt>Control-ReturnE<gt>>
B<NoAutoindentReturn>		B<E<lt>Shift-ReturnE<gt>>
B<Delete>				B<E<lt>DeleteE<gt>>
B<BackSpace>				B<E<lt>BackSpaceE<gt>>
B<DeleteToWordStart>		B<E<lt>Shift-BackSpaceE<gt>>
B<DeleteToWordEnd>		B<E<lt>Shift-DeleteE<gt>>
B<DeleteToLineStart>		B<E<lt>Alt-BackSpaceE<gt>>
B<DeleteToLineEnd>		B<E<lt>Alt-DeleteE<gt>>
B<DeleteWord>			B<E<lt>Control-BackSpaceE<gt>>
B<DeleteLine>			B<E<lt>Control-DeleteE<gt>>

B<InsertControlCode>		B<E<lt>Control-EscapeE<gt>>

B<FocusNext>				B<E<lt>Control-TabE<gt>>
B<FocusPrev>				B<E<lt>Shift-Control-TabE<gt>>

B<FlashMatchingChar>		B<E<lt>Control-bE<gt>>
B<FindMatchingChar>		B<E<lt>Control-jE<gt>>

B<Escape>				B<E<lt>EscapeE<gt>>

B<Tab> 					B<E<lt>TabE<gt>>

B<LeftTab> 				B<E<lt>Shift-TabE<gt>>

B<Copy> 				B<E<lt>Control-cE<gt>>

B<Cut> 					B<E<lt>Control-xE<gt>>

B<Paste> 				B<E<lt>Control-vE<gt>>

B<InlinePaste> 			B<E<lt>Control-VE<gt>>

B<Undo> 				B<E<lt>Control-zE<gt>>

B<Redo>					B<E<lt>Control-ZE<gt>>

B<Destroy>				B<E<lt>DestroyE<gt>>

B<MenuSelect>			B<E<lt>Alt-KeyPressE<gt>>

=head1 AUTHOR

Alessandro Iob E<lt>I<alexiob@iname.com>E<gt>.

=head1 SEE ALSO

L<Tk::Text|Tk::Text>
L<Tk::ROText|Tk::ROText>
L<Tk::TextUndo|Tk::TextUndo>

=head1 KEYWORDS

text, widget

=cut
