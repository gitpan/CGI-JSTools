package CGI::JSTools;

use 5.008001;
use strict;
use warnings;
require CGI;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use CGI::JSTools ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	dynamic_menu
);

our $VERSION = '0.01';

sub dynamic_menu {
    my %parms = (
      'function_name' => 'kid_changer'
    , 'parent_name' => undef
    , 'parent_values' => undef
    , 'parent_default' => undef
    , 'child_name' => undef
    , 'child_hashref' => undef
    , 'child_default' => undef
    , @_
    );
    my $menu;
    $menu .= <<MENU;
function $parms{'function_name'}(parent, child_name) {
    // Get the right parent.
    var parent_id = parent.options[parent.selectedIndex].value;
    var parent_text = parent.options[parent.selectedIndex].text;
    // Loop through the form elements to find the one with
    // the right name.
    my_elements = window.document.forms[0].elements;
    for (var i=0; i <= my_elements.length; i++) {
        if (my_elements[i].name == child_name) {
            child_popup = window.document.forms[0].elements[i];
            break;
        }
    }
    if (parent_id != $parms{'parent_default'}) {
       var child_text_array = child_text[parent_id];
       var child_value_array = child_values[parent_id];
       child_popup.options.length = child_text_array.length;
    // Populate the child object with the appropriate stuff :)
        for (i=0; i < child_text_array.length; i++) {
            child_popup.options[i].text = child_text_array[i];
            child_popup.options[i].value = child_value_array[i];
        }
    } else {
        child_popup.length = 1;
        child_popup.options[0].text = 'Choose a '+parent_text+'
first';
        child_popup.options[0].value = $parms{'child_default'};
    }
    // Make sure child picks don't spill over
    // from one parent to the next.
    child_popup.options[0].selected = true;
}

var child_values = {};
var child_text = {};

MENU
    foreach my $parent_id ( @{ $parms{'parent_values'} } ) {
        $menu .=
          qq(child_values["$parent_id"] = [")
        . join(
            '", "'
          , @{
$parms{'child_hashref'}->{$parent_id}->{'values'} }
          )
        . qq("];\nchild_text["$parent_id"] = [")
        . join(
            '", "'
          , map {
               $parms{'child_hashref'}->{$parent_id}->{'labels'}->{$_}
            } @{ $parms{'child_hashref'}->{$parent_id}->{'values'} }
          )
        . qq{"];\n}
        ;
    }

    return $menu;
}

# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

CGI::JSTools - Perl extension for Linconln Stein's excellent CGI.pm
that helps you write javascript without actually writing javascript,
similar to the way the main branch of CGI.pm can help you write HTML
without actually writing HTML.

=head1 SYNOPSIS

  use CGI;
  use CGI::JSTools;
  my $q = new CGI;

  my $dynamic_menu = dynamic_menu(
    'function_name' => $js_func_name  # Name of the js function
                                      # (defaults to "kid_changer")
  , 'parent_name' => $js_parent_name  # Name of js parent field
  , 'parent_values' => $parent_vals   # Array ref w/order of parent field
  , 'parent_default' => $parent_def   # Parent default value.
  , 'child_name' => $js_child_name    # Name of js child field
  , 'child_hashref' => $child_hashref # Data structure (see below)
  , 'child_default' => $child_def     # For resetting child on change.
  );
  # Typically, these would come from a database or something, but
  # they're spelled out here for illustrative porpoises.
  my $parent_vals = [0, 1, 2, 3];
  my $parent_labels = {
    0 => 'Choose a $parent_name'
  , 1 => 'One'
  , 2 => 'Two'
  , 3 => 'Three'
  );
  my $child_hashref;
  $child_hashref->{0}->{'values'} = [$child_def];
  $child_hashref->{1}->{'values'} = [qw(a b c)];
  $child_hashref->{2}->{'values'} = [qw(d e f)];
  $child_hashref->{3}->{'values'} = [qw(g h i)];
  $child_hashref->{0}->{'labels'} = {
    $child_def => "Pick a $child_name"
  };
  $child_hashref->{1}->{'labels'} = {
    'a' => 'Alpha Geek'
  , 'b' => 'Bravo for the home team.'
  , 'c' => "Charlie Don't Surf!"
  };
  $child_hashref->{2}->{'labels'} = {
    'd' => 'Delta Squared'
  , 'e' => 'Echo Chamber'
  , 'f' => 'Foxtrot is back in style'
  };
  $child_hashref->{3}->{'labels'} = {
    'g' => 'Golf Course'
  , 'h' => 'Hotel California'
  , 'i' => 'India Pale Ale'
  };
  print
    $q->header()
  . $q->start_html(
      -title => $title
    , -script => $dynamic_menu
    )
  . $q->popup_menu(
      -name => $parent_name
    , -values => $parent_vals
    , -labels => $parent_labels
    , -default => $parent_default
    , -onChange => qq{kid_changer(this, $child_name);}
    );
  . $q->popup_menu(
      -name => $child_name
    , -values => $child_def
    , -labels => {$child_def => "Choose a $parent first."}
    )
  # Rest goes here.

=head1 DESCRIPTION

CGI::JSTools::dynamic_menu helps you create javascript functions that
make the contents of the "child" radio group, popup or scrolling list
depend on the choice of the "parent" radio group, popup or scrolling
list.

=head2 EXPORT

dynamic_menu

=head1 SEE ALSO

L<CGI>

=head1 AUTHOR

David Fetter, E<lt>david@fetter.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2003 by David Fetter

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
