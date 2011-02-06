Expandable form.

PACF now supports messages that overflow the default size of the message field(s).
The field expands vertically as required to display all of the information.  The 
form is expanded vetically to as many pages as required.

The auto-print needs to support this as well.

Intention:
1) expand field vertically as required.
2) expand form vertically by same amount field expanded.
3) expand any fields that occupy the same vertical space
   by the same amount.  These occur on forms such as the City Scan
   where three message boxes are aligned in parallel.
4) overflow the form onto a new page - do not merge onto any existing
   pages for multiple page forms.
5) Move any field(s) that are on the edge to the next page.
6) All pages must have footer:
    Retain the footer in its original location
    Add a footer to the new page
7) Adjust page count in footer as required.

Sample(s) for testing
C:\Outpost Oct 2010 drill\XSC\archive\InTray
  R_101023_145451_XSC021_O~R_ICS213_Version_Info.txt
  
position: [left bottom width height]

= = =

1) enable test for vertical resize only if upside down ? found
2) after we've wrapped the text, see if the wrap operation wants a taller figure:
  [outstring,newpos] = textwrap(h_field(thisPage, primaryNdx), {fieldText});
  posit = get(h_field(thisPage, primaryNdx(1)),'Position')
  motionAmount = (newpos(4) - posit(4));
3) we can't move the top, only the bottom.
4) calc a possible new bottom
5) does the proposed new bottom extend into the footer area:
  5 yes: reduce the number of lines in this attempt of the box &
    resize until the box does not go into the header.  Keep all the
    lines that had to be removed for the next, new page.
  5 no: find any boxes other than the footer that have a top higher
    up on the page than the new bottom. if any exist, several steps:
    a) for any box that is to be on a page after the current page, increment
       their page number by one.  No need to alter any other feature.
    b) Note box that has it's top closest to the box being expanded & remember
       the distance between that top and the original bottom of the expanding
       box - we're duplicating the image in that gap on the added page so
       we need to leave room for the image.
    c) for the affected boxes, increment their page number.
    d) using the page # from b, create msg number boxes which duplicate the features
       (position, etc.) of the boxes on the first page (*** note: probably want
       this feature for any form that spans more than one page so make it a general
       purpose call *** )
    e) for the boxes from (b), repeat their original vertical position order from top to
       bottom such that their position relative to the lowest msg box is the same as they
       were to the expanded box.
    f)